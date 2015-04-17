(asdf:defsystem #:clscript
  :description "ANSI Common Lisp standard implementation compiling to JavaScript"
  :author "Florian Margaine <florian@margaine.com>"
  :license "MIT License"
  :serial t
  :depends-on (:cl-ppcre :sb-cltl2 :alexandria)
  :in-order-to ((asdf:test-op (asdf:test-op :clscript-test)))
  :components ((:module "src"
                        :components
                        ((:file "package")
                         (:file "forms")
                         (:file "transpilers")
                         (:file "transpilers/sbcl")
                         (:file "transpilers/common-lisp")
                         (:file "clscript")))))
