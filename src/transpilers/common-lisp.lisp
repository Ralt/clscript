(in-package #:clscript)

(defun default-transpiler (form)
  "Called when no transpiler exists.
It's just a basic (foo bar) -> foo(bar) transpiler."
  (format nil "~A(~{~A~^, ~})"
          (string-downcase (first form))
          (mapcar #'transpile-form (rest form))))

(defun transpile-atom (atom)
  (cond ((eq (type-of atom) 'symbol) (string-downcase (symbol-name atom)))
        (t atom)))

(define-transpiler "common-lisp:progn" (form)
  (remove nil (mapcar #'transpile-form (rest form))))

(define-transpiler "common-lisp:eval-when" (form)
  "Voluntarily do nothing"
  (declare (ignore form)))


(defun transpile-function (name args body)
  (format nil "function ~A(~{~A~^, ~}) {~%~A~%}"
          name args (transpile-function-body body)))

(defun transpile-function-body (forms)
  (cond ((eq (type-of forms) 'symbol)
         (transpile-return-form forms))
        (t (let ((reversed-body (reverse forms)))
             (format nil "~{~A;~%~}~A"
                     (mapcar #'transpile-form (reverse (rest reversed-body)))
                     (transpile-return-form (first reversed-body)))))))

(defun transpile-return-form (form)
  (format nil "return ~A;" (transpile-form form)))

(define-transpiler "common-lisp:block" (form)
  (format nil "(~A());"
          (transpile-function (string-downcase (second form))
                              nil
                              (third form))))
