(in-package #:clscript)


(defun transpile (code)
  (let ((forms (mapcar #'(lambda (form)
                           (sb-cltl2:macroexpand-all (read-from-string form)))
                       (get-forms code))))
    (mapcar #'transpile-form forms)))

(defun transpile-form (form)
  (let ((transpiler (get-transpiler form)))
    (if transpiler
        (funcall transpiler form)
        (default-transpiler form))))
