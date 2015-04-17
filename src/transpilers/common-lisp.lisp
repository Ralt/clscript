(in-package #:clscript)

(defun default-transpiler (form)
  "Called when no transpiler exists.
It's just a basic (foo bar) -> foo(bar) transpiler."
  (format nil "~A(~{~A~^, ~})"
          (string-downcase (first form))
          (mapcar #'transpile-form (rest form))))

(define-transpiler "common-lisp:progn" (form)
  (remove nil (mapcar #'transpile-form (rest form))))

;;; Voluntarily do nothing
(define-transpiler "common-lisp:eval-when" (form)
  (declare (ignore form)))

(define-transpiler "common-lisp:block" (form)
  (format nil "(~A());"
          (transpile-function (string-downcase (second form))
                              nil
                              (third form))))

;;; Returning a function is required to support things like:
;;; (defun foo ()
;;;   (setf *bar* (if t
;;;                   1
;;;                   2)))
(define-transpiler "common-lisp:if" (form)
  (format nil "(function() {~%if (~A) {~%~A~%} else {~%~A~%}~%}());"
          (transpile-form (second form))
          (transpile-function-body (if (and (eq (type-of (third form)) 'cons)
                                            (eq (first (third form)) 'progn))
                                       (rest (third form))
                                       (third form)))
          (transpile-function-body (if (and (eq (type-of (fourth form)) 'cons)
                                            (eq (first (fourth form)) 'progn))
                                       (rest (fourth form))
                                       (fourth form)))))

(define-transpiler "common-lisp:let" (form)
  (format nil "(function() {~%~{~A;~^~%~}~%~A~%}());"
          (transpile-let (second form))
          (transpile-function-body (rest (rest form)))))

(defun transpile-let (declarations)
  (mapcar #'transpile-declaration declarations))

(defun transpile-declaration (declaration)
  (format nil "var ~A = ~A"
          (transpile-atom (first declaration))
          (transpile-form (second declaration))))

(defun transpile-atom (atom)
  (cond
    ((eq atom nil) "null")
    ((eq (type-of atom) 'symbol) (string-downcase (symbol-name atom)))
    (t atom)))

(defun transpile-function (name args body)
  (format nil "function ~A(~{~A~^, ~}) {~%~A~%}"
          name args (transpile-function-body body)))

(defun transpile-lambda (args body)
  (format nil "function(~{~A~^, ~}) {~%~A~%}"
          args (transpile-function-body body)))

(defun transpile-function-body (forms)
  (cond ((eq (type-of forms) 'symbol) (transpile-return-form forms))
        (t (let ((reversed-body (reverse forms)))
             (format nil "~{~A;~%~}~A"
                     (mapcar #'transpile-form (reverse (rest reversed-body)))
                     (transpile-return-form (first reversed-body)))))))

(defun transpile-return-form (form)
  (format nil "return ~A;" (transpile-form form)))
