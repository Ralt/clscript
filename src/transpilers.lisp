(in-package #:clscript)


(defvar *transpilers* (make-hash-table :test 'equal))

(defun default-transpiler (form)
  "Called when no transpiler exists.
It's just a basic (foo bar) -> foo(bar) transpiler."
  (format nil "~A(~{~S~^, ~});"
          (string-downcase (first form))
          (mapcar #'transpile-form (rest form))))

(defun get-transpiler (form)
  (let* ((first-symbol (first form))
         (symbol-package (package-name (symbol-package first-symbol)))
         (symbol-name (symbol-name first-symbol)))
    (multiple-value-bind (transpiler presentp)
              (gethash (concatenate 'string symbol-package ":" symbol-name) *transpilers*)
            (when presentp transpiler))))

(defun transpile-atom (atom)
  "Transpiles a single atom.
Many atoms are replaceable without change, but a lot also need replacement,
like the gensym-generated variables."
  atom)

(defmacro define-transpiler (name args &body body)
  `(setf (gethash ,(string-upcase name) *transpilers*)
         #'(lambda ,args
             ,@body)))

(define-transpiler "common-lisp:progn" (form)
  (mapcar #'transpile-form (rest form)))

(define-transpiler "common-lisp:eval-when" (form)
  "Voluntarily do nothing"
  (declare (ignore form)))

(define-transpiler "sb-impl:%defun" (form)
  (format nil "function ~A(~{~A~^, ~}) {~%~A~%}"
          (string-downcase (symbol-name (second (third form))))
          (mapcar #'string-downcase (third (third form)))
          (transpile-form (third (fourth (third form))))))

(define-transpiler "common-lisp:block" (form)
  (format nil "~A:~% ~A"
          (string-downcase (second form))
          (transpile-form (third form))))
