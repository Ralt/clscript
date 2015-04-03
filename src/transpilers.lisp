(in-package #:clscript)


(defvar *transpilers* (make-hash-table :test 'equal))

(defun default-transpiler (form)
  "Called when no transpiler exists.
It's just a basic (foo bar) -> foo(bar) transpiler."
  form)

(defun get-transpiler (form)
  (multiple-value-bind (transpiler presentp)
      (gethash (first form) *transpilers*)
    (when presentp transpiler)))

(defmacro define-transpiler (name args &body body)
  `(setf (gethash ,(symbol-name name) *transpilers*)
         #'(lambda ,args
             ,@body)))

(define-transpiler progn (form)
  form)
