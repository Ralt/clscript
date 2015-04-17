(in-package #:clscript)


(defvar *transpilers* (make-hash-table :test 'equal))

(defun default-transpiler (form)
  "Called when no transpiler exists.
It's just a basic (foo bar) -> foo(bar) transpiler."
  (format nil "~A(~{~S~^, ~})"
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
  (cond ((eq (type-of atom) 'symbol) (string-downcase (symbol-name atom)))
        (t atom)))

(defmacro define-transpiler (name args &body body)
  `(setf (gethash ,(string-upcase name) *transpilers*)
         #'(lambda ,args
             ,@body)))

(define-transpiler "common-lisp:progn" (form)
  (remove nil (mapcar #'transpile-form (rest form))))

(define-transpiler "common-lisp:eval-when" (form)
  "Voluntarily do nothing"
  (declare (ignore form)))

(define-transpiler "sb-impl:%defun" (form)
  (transpile-function (string-downcase (symbol-name (second (third form))))
                      (mapcar #'string-downcase (third (third form)))
                      (rest (rest (fourth (third form))))))

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
