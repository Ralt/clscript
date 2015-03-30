(asdf:defsystem #:clscript
  :description "ANSI Common Lisp standard implementation compiling to JavaScript"
  :author "Florian Margaine <florian@margaine.com>"
  :license "MIT License"
  :serial t
  :depends-on (:cl-ppcre)
  :in-order-to ((asdf:test-op (asdf:test-op :clscript-test)))
  :components ((:module "src"
                        :components
                        ((:file "package")
                         (:file "clscript")))))
