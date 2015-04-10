(in-package #:clscript)


(defvar *transpilers* (make-hash-table :test 'equal))

(defun default-transpiler (form)
  "Called when no transpiler exists.
It's just a basic (foo bar) -> foo(bar) transpiler."
  (format nil "~A(~{~S~^, ~});"
          (string-downcase (first form))
          (mapcar #'transpile-form (rest form))))

(defun get-transpiler (form)
  (multiple-value-bind (transpiler presentp)
      (gethash (symbol-name (first form)) *transpilers*)
    (when presentp transpiler)))

(defun transpile-atom (atom)
  "Transpiles a single atom.
Many atoms are replaceable without change, but a lot also need replacement,
like the gensym-generated variables."
  atom)

(defmacro define-transpiler (name args &body body)
  `(setf (gethash ,(string-upcase name) *transpilers*)
         #'(lambda ,args
             ,@body)))

(define-transpiler "progn" (form)
  (mapcar #'transpile-form (rest form)))
