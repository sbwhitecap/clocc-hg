;;; Prompt
;;;
;;; Copyright (C) 1997-2000 by Sam Steingold.
;;; This is Free Software, covered by the GNU GPL (v2)
;;; See http://www.gnu.org/copyleft/gpl.html
;;;
;;; $Id$
;;; $Source$

(eval-when (compile load eval)
  (require :cllib-base (translate-logical-pathname "clocc:src;cllib;base"))
  ;; `getenv'
  (require :port-sys (translate-logical-pathname "port:sys")))

(in-package :cllib)

#+(and clisp lisp=cl)
(eval-when (compile load eval) (import 'ext:package-short-name :cllib))

(export '(package-short-name set-cllib-prompt))

#-(and clisp lisp=cl)
(defun package-short-name (pkg)
  "Return the shortest (nick)name of the package."
  (declare (type package pkg))
  (let ((name (reduce (lambda (st0 st1)
                        (declare (simple-string st0 st1))
                        (if (> (length st0) (length st1)) st1 st0))
                      (package-nicknames pkg) :initial-value
                      (package-name pkg))))
    (case *print-case*
      (:upcase (string-upcase name))
      (:downcase (string-downcase name))
      (:capitalize (string-capitalize name))
      (t name))))

(defun set-cllib-prompt ()
  "Reset the prompt according to CLLIB."
  #+(or allegro clisp cmu)
  (let* ((cmd-idx 0)
         (fontp (let ((term (getenv "TERM")))
                  (or (null term)
                      (string-equal term "dumb")
                      (string-equal term "emacs"))))
         (beg-bold (if fontp "" "[1m"))
         #-allegro
         (beg-it   (if fontp "" "[7m"))
         (end-all  (if fontp "" "[m"))
         (func (lambda ()
                 (format nil "~a~a~a~a[~:d]:~a " beg-it
                         (package-short-name *package*)
                         end-all beg-bold (incf cmd-idx) end-all))))
    #+allegro (declare (ignore cmd-idx))
    #+clisp
    (let ((symbol (or (find-symbol "*PROMPT*" #+lisp=cl "EXT" #-lisp=cl "LISP")
                      (find-symbol "*PROMPT-BODY*" "CUSTOM"))))
      (setf (symbol-value symbol) func))
    #+cmu (setq lisp::*prompt* func)
    #+allegro
    (setq tpl:*prompt* (concatenate 'string beg-bold tpl:*prompt* end-all)))
  #-(or allegro clisp cmu)
  (error 'not-implemented :proc 'set-cllib-prompt))

(provide :cllib-prompt)
;; prompt.lisp ends here
