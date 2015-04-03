(in-package #:clscript-test)


(is (clscript::get-forms "(foo \"foo\" \"bar\" 1)")
    '("( foo \"foo\" \"bar\" 1 )"))

(is (clscript::get-forms "(1)")
    '("( 1 )"))

(is (clscript::get-forms "(1) (1)")
    '("( 1 )" "( 1 )"))

(is (clscript::get-forms "(foo (bar))")
    '("( foo ( bar ) )"))

(is (clscript::get-forms "(defun foo () \"bar\")")
    '("( defun foo ( ) \"bar\" )"))

(is (clscript::get-forms "foo")
    '("foo"))

(is (clscript::get-forms "foo (bar)")
    '("foo" "( bar )"))

(is (clscript::get-forms "(defun foo (a) (let ((bar (ash a 1))) (when a bar))) (foo 1) bar (baz)")
    '("( defun foo ( a ) ( let ( ( bar ( ash a 1 ) ) ) ( when a bar ) ) )"
      "( foo 1 )"
      "bar"))
