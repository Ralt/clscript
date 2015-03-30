(asdf:defsystem #:clscript
  :description "ANSI Common Lisp standard implementation compiling to JavaScript"
  :author "Florian Margaine <florian@margaine.com>"
  :license "MIT License"
  :serial t
  :depends-on (:cl-ppcre)
  :components ((:file "package")
               (:file "clscript")))
