;;; -*- Lisp -*-
;;;
;;; CLLIB - a library of useful utilities
;;;
;;; $Id$
;;; $Source$
;;;
;;; when adding a file to CLLIB, one has to modify the following:
;;; 1. cllib.system (defsystem)
;;; 2. Makefile ($(SOURCES))
;;; 3. cllib.html (file list)

(push (translate-logical-pathname "clocc:src;port;") asdf:*central-registry*)
(push (translate-logical-pathname "clocc:src;tools;metering;") asdf:*central-registry*)

(asdf:defsystem :cllib
    :author ("Sam Steingold <sds@gnu.org>")
    :licence "LGPL"
    :description "a library of useful utilities"
    :depends-on (:port :metering :cl-html-parse)
    :components
    ((:file "animals" :depends-on
            ("base" "string" "miscprint" "fileio" "closio" "symb"))
     (:file "autoload" :depends-on ("base" "fileio"))
     (:file "base")
     (:file "base64" :depends-on ("base"))
     (:file "card" :depends-on
            ("base" "withtype" "closio" "tilsla" "string" "date" "url"))
     (:file "check" :depends-on ("base" "log" "math"))
     (:file "clhs" :depends-on
            ("base" "withtype" "string" "fileio" "log" "html"))
     (:file "closio" :depends-on ("base"))
     (:file "csv" :depends-on ("base" "simple" "symb" "log"))
     (:file "cvs" :depends-on ("base" "string" "fileio" "date" "miscprint"))
     (:file "data" :depends-on
            ("base" "csv" "math" "gnuplot" "miscprint" "lift"))
     (:file "date" :depends-on
            ("base" "simple" "string" "sorted" "log" "withtype" #+cmu"closio"))
     (:file "datedl" :depends-on
            ("base" "withtype" "date" "laser" "math" "symb"))
     (:file "doall" :depends-on ("base"))
     (:file "elisp" :depends-on ("base" "closio" "list"))
     (:file "fileio" :depends-on ("base" "withtype" "symb" "log" "string"))
     (:file "fin" :depends-on ("base" "math" "tilsla" "withtype" "gnuplot"))
     (:file "geo" :depends-on
            ("base" "withtype" "symb" "fileio" "html" "tilsla" "url"))
     (:file "getopt" :depends-on ("base" "symb"))
     (:file "gnuplot" :depends-on ("base" "date" "datedl" "math" "stat"))
     (:file "gq" :depends-on ("base" "withtype" "html" "url" "gnuplot"))
     (:file "grepfin" :depends-on ("base" "csv"))
     (:file "h2lisp" :depends-on ("base" "withtype" "html"))
     (:file "html" :depends-on ("base" "xml" "url"))
     (:file "htmlgen" :depends-on ("base"))
     (:file "inspect" :depends-on
            ("base" "simple" "closio" "url" "string" "htmlgen"))
     (:file "iter" :depends-on ("base" "simple" "withtype" "log" "math"))
     (:file "laser" :depends-on ("base" "log"))
     (:file "lift" :depends-on ("base" "math" "gnuplot"))
     (:file "list" :depends-on ("base" "simple"))
     (:file "log" :depends-on ("base" "withtype" "tilsla" "simple"))
     (:file "math" :depends-on
            ("base" "simple" "withtype" "fileio" "log" "list"))
     (:file "matrix" :depends-on ("base" "withtype"))
     (:file "miscprint" :depends-on ("base" "simple"))
     (:file "munkres" :depends-on ("base"))
     (:file "bayes" :depends-on
            ("base" "log" "miscprint" "math" "sorted" "matrix"))
     (:file "ocaml" :depends-on ("base"))
     #+clisp (:file "octave" :depends-on ("base"))
     (:file "prompt" :depends-on ("base"))
     (:file "rng" :depends-on ("base" "withtype"))
     (:file "rpm" :depends-on ("base" "url"))
     (:file "server" :depends-on ("base" "log" "prompt"))
     (:file "simple" :depends-on ("base"))
     (:file "sorted" :depends-on ("base" "tilsla" "math"))
     (:file "stat" :depends-on ("base" "math" "withtype" "matrix"))
     (:file "string" :depends-on ("base" "withtype"))
     (:file "symb" :depends-on ("base"))
     (:file "tests" :depends-on
            ("base" "string" "date" "url" "rpm" "elisp" "xml" "cvs" "munkres"
             "matrix" "simple" "iter" "list"))
     (:file "tilsla" :depends-on ("base" "withtype"))
     (:file "url" :depends-on ("base" "withtype" "symb" "string" "fileio"
                               "log" "simple" "tilsla" "date" "base64"))
     (:file "withtype" :depends-on ("base"))
     (:file "xml" :depends-on
            ("base" "string" "withtype" "closio" "log" "fileio" "url"))))
