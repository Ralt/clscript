(in-package #:clscript-test)

(is (clscript::tokenize "(foo \"foo\" \"bar\" 1)")
    '("(" "foo" "\"foo\"" "\"bar\"" "1" ")"))

(is (clscript::tokenize "(1)")
    '("(" "1" ")"))

(is (clscript::tokenize "(1) (1)")
    '("(" "1" ")" "(" "1" ")"))

(is (clscript::tokenize "(foo (bar))")
    '("(" "foo" "(" "bar" ")" ")"))

(is (clscript::tokenize "(defun foo () \"bar\")")
    '("(" "defun" "foo" "(" ")" "\"bar\"" ")"))

(is (clscript::tokenize "foo")
    '("foo"))
