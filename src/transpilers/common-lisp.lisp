(in-package #:clscript)

(defun default-transpiler (form)
  "Called when no transpiler exists.
It's just a basic (foo bar) -> foo(bar) transpiler."
  (format nil "~A(~{~A~^, ~})"
          (string-downcase (first form))
          (mapcar #'transpile-form (rest form))))

(define-transpiler "common-lisp:progn" (form)
  (remove nil (mapcar #'transpile-form (rest form))))

(define-transpiler "common-lisp:eval-when" (form)
  "Voluntarily do nothing"
  (declare (ignore form)))

(define-transpiler "common-lisp:block" (form)
  (format nil "(~A());"
          (transpile-function (string-downcase (second form))
                              nil
                              (third form))))

(define-transpiler "common-lisp:if" (form)
  (format nil "(function() {~%if (~A) {~%~A~%} else {~%~A~%}~%}());"
          (transpile-form (second form))
          (transpile-function-body (third form))
          (transpile-function-body (fourth form))))

(defun transpile-atom (atom)
  (cond
    ((eq atom nil) "null")
    ((eq (type-of atom) 'symbol) (string-downcase (symbol-name atom)))
    (t atom)))

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
