(asdf:defsystem #:clscript-test
  :description "Test package for clscript"
  :license "MIT License"
  :serial t
  :depends-on (:clscript :prove)
  :defsystem-depends-on (:prove-asdf)
  :components ((:module "tests"
                        :components
                        ((:file "package")
                         (:test-file "tokenize")))))
