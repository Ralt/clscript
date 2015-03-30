(in-package #:clscript-test)

(is (clscript::tokenize "(foo \"foo\" \"bar\" 1)")
    '("(" "foo" "\"foo\"" "\"bar\"" "1" ")"))

(is (clscript::tokenize "(1)")
    '("(" "1" ")"))
