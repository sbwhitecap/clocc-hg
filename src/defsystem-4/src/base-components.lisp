;;; -*- Mode: Lisp -*-

;;; DEFSYSTEM 4.0

;;; base-components.lisp --

(in-package "MAKE-4")

(defvar *source-pathname-default*
  (merge-pathnames (make-pathname :directory (list :absolute "usr" "local")
				  :name "mk-defsys-default-component-name"
				  )))

(defvar *binary-pathname-default*
  (merge-pathnames
   (make-pathname :directory (list :absolute "usr" "local")
		  :name "mk-defsys-default-component-name"
		  :type (pathname-type
			 (compile-file-pathname *default-pathname-defaults*))
		  )))


;;; topological-sort-node-mixin --

(defclass topological-sort-node-mixin ()
  ((color :accessor topsort-color
	  :initform :white
	  :type (member :gray :black :white))
   )
  (:documentation
   "A 'mixin' class used to gather the topological sort field(s).")
  )


;;; initially-finally-component-mixin --

(defclass initially-finally-component-mixin ()
  ((initially-do :accessor component-initially-do
		 :initarg :initially-do) ; Form to evaluate before the
					 ; operation.
   (finally-do :accessor component-finally-do
	       :initarg :finally-do)	; Form to evaluate after the operation.
   )
  (:default-initargs
    :initially-do #'(lambda (&rest args) (declare (ignore args)) t)
    :finally-do #'(lambda (&rest args) (declare (ignore args)) t))
  (:documentation
   "A 'mixin' class used when we want 'initially' and 'finally' actions.")
  )


;;; storage-component-mixin --
;;; A mixin class that contains all the relevant slots that are needed
;;; to map a component to a `generic' storage area (most of the time a
;;; file system entity).
;;; This is factored apart to better modularize this crucial part of
;;; the code.

(defclass storage-component-mixin ()
  ((s-dirty-bit :accessor source-pathname-computations-dirty-bit
		:initform t
		:type (member t nil))
   
   (b-dirty-bit :accessor binary-pathname-computations-dirty-bit
		:initform t
		:type (member t nil))
   
   ;; host -- The pathname host in a human readable form. I.e. the
   ;; value of this slot is limited to a subset of the 'valid pathname
   ;; host' values acceptable by the ANSI Spec.  I.e. the values for
   ;; this slot must be either a string (cfr. the ANCI CL spec: we
   ;; don't allow a list of strings here) or the value :UNSPECIFIC (or
   ;; NIL - see below). This value is then "parsed" (using
   ;; PARSE-NAMESTRING and maybe LOGICAL-PATHNAME-TRANSLATIONS) to
   ;; yield the actual host to be used subsequently. The "parsed" host
   ;; is stored in the slot COMPUTED-HOST.  The initial value can be
   ;; NIL to mean that the slot value must be taken form the parent
   ;; component.
   (host :accessor component-host
	 :initarg :host
	 :type (or null string (member :unspecific)))

   ;; compute-host -- See comment about 'host' slot.
   (computed-host :accessor component-computed-host
		  :initform :unspecific)

   (device :accessor component-device
	   :initarg :device)		; The pathname device.


   
   (source-pathname :accessor component-source-pathname
		    :initarg :source-pathname)
   (source-extension :accessor component-source-extension
		     :initarg :source-extension
		     :type (or null string)) ; A string, e.g.,
					     ; "lisp". If NIL,  uses
					     ; default, where
					     ; `default' is to be
					     ; interpreted based on
					     ; context. (E.g. for
					     ; files included in
					     ; modules etc.)

   ;; The next slot is used for caching purposes.
   (computed-source-pathname :accessor computed-source-pathname
			     :initform nil)


   (binary-pathname :accessor component-binary-pathname
		    :initarg :binary-pathname)
   (binary-extension :accessor component-binary-extension
		     :initarg :binary-extension
		     :type (or null string)) ; A string, e.g.,
					     ; "fasl". If NIL,  uses
					     ; default for
					     ; machine-type.
   ;; The next slot is used for caching purposes.
   (computed-binary-pathname :accessor computed-binary-pathname
			     :initform nil)


   ;; error-log-pathname -- Will have to go somewhere else.
   (error-log-pathname :accessor component-error-log-pathname
		       :initarg :error-log)


   ;; Parsing and construction support.

   (storage-slots :reader storage-slots
		  :initform '(:host
			      :device
			      :source-root-dir
			      :source-pathname
			      :source-extension
			      :binary-root-dir
			      :binary-pathname
			      :binary-extension
			      ))
   (locally-defined-storage-slots :accessor locally-defined-storage-slots
				  :initform ()
				  :type list)
   (inherited-storage-slots :accessor inherited-storage-slots
			    :initform ()
			    :type list)
   )
  (:default-initargs
    :host nil				; This default is important
					; for PARSE-NAMESTRING.
    :device nil
    :source-pathname nil
    :source-extension nil
    :binary-pathname nil
    :binary-extension nil
    :version :newest
    )
  (:documentation
   "A `mixin' class used to encapsulate `storage' related functionalities.")
  )


(define-condition component-not-available-on-storage (file-error)
  ((c :reader component-of
      :initarg :component))
  (:report (lambda (cnaos stream)
	     (format stream
		     "Component ~S is not stored in the file system."
		     (component-of cnaos)))))


;;; component-language-mixin --
;;; The following three slots are used to provide for alternate compilation
;;; and loading functions for the files contained within a component. If
;;; a component has a compiler or a loader specified, those functions are
;;; used. Otherwise the functions are derived from the language. If no
;;; language is specified, it defaults to Common Lisp (:lisp). Other current
;;; possible languages include :scheme (PseudoScheme) and :c, but the user
;;; can define additional language mappings. Compilation functions should 
;;; accept a pathname argument and a :output-file keyword; loading functions
;;; just a pathname argument. The default functions are #'compile-file and
;;; #'load. Unlike fdmm's SET-LANGUAGE macro, this allows a defsystem to 
;;; mix languages.

#+now-in-language-support
(defclass component-language-mixin ()
  ((language :accessor component-language
	     :initarg :language
	     :type (or null symbol))
   (compiler :accessor component-compiler
	     :initarg :compiler
	     :type (or null function))
   (loader   :accessor component-loader
	     :initarg :loader
	     :type (or null function))
   )
  (:default-initargs :language :common-lisp)
  (:documentation
   "A 'mixin' class used to specify a component language other than CL."))


;;; component --

(defclass component (topological-sort-node-mixin)
  ((type :accessor component-type
	 :initarg :type
	 :type (or null
		   (member :defsystem
			   :system
			   :subsystem
			   :module
			   :file
			   :private-file)))
   (name :accessor component-name
	 :initarg :name
	 :type (or symbol string))

   (name-case :accessor component-name-case
	      :initarg :name-case
	      :type (member :uppercase
			    :downscase
			    :preserve))	; TO control how a 'symbol'
					; name is translated into a
					; string.

   (part-of :accessor component-part-of
	    :initform nil)		; The component within which this one
					; is defined as part-of.  In
					; DF3.x this was the 'parent'
					; variable passed around at
					; construction time.

   (package :accessor component-package
	    :initarg :package)		; Package for use-package.


   (depends-on :accessor component-depends-on
	       :initarg :depends-on
	       :type list)		; A list of the components
					; this one depends on. may
					; refer only to the components
					; at the same level as this
					; one.

   (indent :accessor component-indent
	   :initarg :indent
	   :type (mod 1024))		; Number of characters of indent in
					; verbose output to the user.

   (proclamations :accessor component-proclamations
		  :initarg :proclamations) ; Compiler options, such as
					   ; '(optimize (safety 3)).

   (load-print :accessor component-load-print
	       :initarg :load-print)

   (compile-print :accessor component-compile-print
		  :initarg :compile-print)

   (load-verbose :accessor component-load-verbose
		 :initarg :load-verbose)

   (compile-verbose :accessor component-compile-verbose
		    :initarg :compile-verbose)

   (compilable-p :accessor component-can-be-compiled-p
		 :initform t)

   (compiler-options :accessor component-compiler-options
		     :initform '())

   (external-format :accessor component-external-format
		    :initarg :external-format)
   

   (compile-form :accessor component-compile-form
		 :initarg :compile-form) ; For foreign libraries.
   (load-form :accessor component-load-form
	      :initarg :load-form)	; For foreign libraries.

   ;; The last time a component has "changed" w.r.t. its own
   ;; definition or the item it represents.
   ;; This means that the value contained here reflects the last time
   ;; that the item represented by the component has actually changed
   ;; the state of the CL system.
   ;; E.g. the last time a file has been loaded in its source or
   ;; binary form.  For other component types, the value is derived
   ;; from the value attached to their "true file system"
   ;; subcomponents - i.e. components derived from
   ;; STORAGE-COMPONENT-MIXIN.
   (changed-timestamp :accessor component-changed-timestamp
		      :initform 0
		      :type (integer 0 *)) ; A 'universal' time.
   
   ;; If load-only is T, will not compile the file on operation :compile.
   ;; In other words, for files which are :load-only T, loading the file
   ;; satisfies any demand to recompile.
   (load-only :accessor component-load-only
	      :initarg :load-only)	; If T, will not compile this
					; file on operation :compile.

   ;; If compile-only is T, will not load the file on operation :compile.
   ;; Either compiles or loads the file, but not both. In other words,
   ;; compiling the file satisfies the demand to load it. This is useful
   ;; for PCL defmethod and defclass definitions, which wrap a 
   ;; (eval-when (compile load eval) ...) around the body of the definition.
   ;; This saves time in some lisps.
   (compile-only :accessor component-compile-only
		 :initarg :compile-only) ; If T, will not load this
					 ; file on operation :compile.
   #| ISI Extension |#
   (load-always :accessor component-load-always
		:initarg :load-always
		:type (member t nil))	; If T, will force loading
					; even if file has not
					; changed.

   (if-feature :accessor component-if-feature
	       :initarg :if-feature)

   (os-type :accessor component-os-type
	    :initarg :os-type
	    :type symbol)

   (version :accessor component-version	; Default is :NEWEST.
	    :initarg :version)

   (documentation :accessor component-documentation
		  :initarg :documentation
		  :type (or null string)) ; Optional documentation slot
   )
  (:default-initargs :type nil
    :name nil
    :name-case :downcase
    :indent 0

    :depends-on ()

    :package nil

    :proclamations nil
    :load-form #'(lambda (&rest args) (declare (ignore args)) t)

    :load-only nil
    :compile-only nil
    :load-always nil

    :load-print *load-print*
    :compile-print *compile-print*
    :load-verbose *load-verbose*
    :compile-verbose *compile-verbose*
    :external-format :default

    :if-feature nil
    :os-type (cl.env:os-feature-tag cl.env:*operating-system*)
    
    :documentation nil
    ))


;;; dependency --
;;; Dependencies are a little hairy, because of backward
;;; compatibility.  Hence the extra accessor methods on 'component',
;;; 'symbol' and 'string'.  I.e. the dependency list may or may not be
;;; normalized to a list of 'dependency' instances.

(defparameter *known-dependency-types*
  (list :load :compile :clean))

(defclass dependency ()
  ((action :accessor dependency-on-actions
	   :initarg :action
	   :type list
	   )
   (component :accessor dependency-on-component
	      :initarg :component
	      :type (or null string symbol component))
   )
  (:default-initargs :action '(:compile :load) :component nil))

(defmethod dependency-on-component ((c component)) c)
(defmethod dependency-on-component ((c symbol)) c)
(defmethod dependency-on-component ((c string)) c)

(defgeneric select-component-dependencies (component action))


;;; stored-component --

(defclass stored-component (component storage-component-mixin)
  ()
  )


(defclass hierarchical-component (component)
  ((components :accessor component-components
	       :initarg :components
	       :type list)		; A list of components
					; comprising this component's
					; definition.
   (components-table :accessor components-table
		     :initform nil
		     :type hash-table)	; An EQUALP hash table which
					; indexes the components.
					; This is inherited from the
					; ancestor system.
		     
   )
  (:documentation "The Hierarchical Component Class.
The superclass of all components which allow sub-components.")
  (:default-initargs :components ()))


(defclass simple-component (component)
  ()
  (:documentation "The Simple Component Class.
The superclass of all components which do not allow sub-components."))


(defclass standard-hierarchical-component (hierarchical-component
					   stored-component
					   initially-finally-component-mixin)
  ()
  )

(defclass standard-simple-component (simple-component
				     stored-component
				     initially-finally-component-mixin)
  ()
  )

;;; end of file -- base-components.lisp --
