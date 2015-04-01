(in-package #:clscript-test)


(is (clscript::parse "(foo \"foo\" \"bar\" 1)")
    '("foo" "\"foo\"" "\"bar\"" "1"))

(is (clscript::parse "(1)")
    '("1"))

(is (clscript::parse "(1) (1)")
    '("1" "1"))

(is (clscript::parse "(foo (bar))")
    '("foo" ("bar")))

(is (clscript::parse "(defun foo () \"bar\")")
    '("defun" "foo" () "\"bar\""))

(is (clscript::parse "foo")
    "foo")
