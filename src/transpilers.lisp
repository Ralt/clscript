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

(defun transpile-atom (atom)
  "Transpiles a single atom.
Many atoms are replaceable without change, but a lot also need replacement,
like the gensym-generated variables."
  (format nil "~S" atom))

(defmacro define-transpiler (name args &body body)
  `(setf (gethash ,(string-upcase name) *transpilers*)
         #'(lambda ,args
             ,@body)))

(define-transpiler "progn" (form)
  (mapcar #'transpile-form (rest form)))
