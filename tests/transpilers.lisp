(in-package #:clscript-test)


(is (funcall (clscript::get-transpiler '(progn (foo 1) (bar))) '(progn (foo 1) (bar)))
    '("foo(1);" "bar();"))

(let ((form (third
             (sb-cltl2:macroexpand-all (read-from-string "(defun foo (a b) (bar))")))))
  (is (funcall (clscript::get-transpiler form) form)
      "function foo(a, b) {
bar();
}"))
