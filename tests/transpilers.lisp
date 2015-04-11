(in-package #:clscript-test)


(defun get-forms (code)
  (sb-cltl2:macroexpand-all (read-from-string code)))

(defmacro test-transpilation (forms code)
  (let ((forms-var (gensym)))
    `(let ((,forms-var (get-forms ,forms)))
       (is (funcall (clscript::get-transpiler ,forms-var) ,forms-var)
           ,code))))

(plan 2)

(test-transpilation
 "(progn (foo 1) (bar))"
 '("foo(1);" "bar();"))

(test-transpilation
 "(defun foo (a b) (bar))"
 '("function foo(a, b) {
bar();
}"))

(finalize)
