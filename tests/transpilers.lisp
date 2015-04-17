(in-package #:clscript-test)


(defun get-forms (code)
  (sb-cltl2:macroexpand-all (read-from-string code)))

(defmacro test-transpilation (forms code)
  (let ((forms-var (gensym)))
    `(let ((,forms-var (get-forms ,forms)))
       (is (funcall (clscript::get-transpiler ,forms-var) ,forms-var)
           ,code))))

(plan 9)

(test-transpilation
 "(progn (foo 1) (bar))"
 '("foo(1)" "bar()"))

(test-transpilation
 "(defun foo (a b) (bar))"
 '("function foo(a, b) {
return bar();
}"))

(test-transpilation
 "(defun foo () bar)"
 '("function foo() {
return bar;
}"))

(test-transpilation
 "(defun foo () (bar) (baz))"
 '("function foo() {
bar();
return baz();
}"))

(test-transpilation
 "(block foo bar)"
 "(function foo() {
return bar;
}());")

(test-transpilation
 "(defun foo (a b) (foo (bar a) b))"
 '("function foo(a, b) {
return foo(bar(a), b);
}"))

(test-transpilation
 "(if foo bar)"
 "(function() {
if (foo) {
return bar;
} else {
return null;
}
}());")

(test-transpilation
 "(when (foo 1) (bar (baz 2)))"
 "(function() {
if (foo(1)) {
return bar(baz(2));
} else {
return null;
}
}());")

(test-transpilation
 "(let ((foo 1)) foo)"
 "(function() {
var foo = 1;
return foo;
}());")

(finalize)
