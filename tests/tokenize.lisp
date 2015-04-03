(in-package #:clscript-test)


(plan 7)

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

(is (clscript::tokenize "(defun foo (a) (let ((bar (ash a 1))) (when a bar))) (foo 1) bar")
    '("(" "defun" "foo" "(" "a" ")" "(" "let" "(" "(" "bar" "(" "ash" "a" "1" ")" ")" ")" "(" "when" "a" "bar" ")" ")" ")" "(" "foo" "1" ")" "bar"))

(finalize)
