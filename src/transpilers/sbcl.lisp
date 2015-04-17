(in-package #:clscript)


(define-transpiler "sb-impl:%defun" (form)
  (transpile-function (string-downcase (symbol-name (second (third form))))
                      (mapcar #'string-downcase (third (third form)))
                      (rest (rest (fourth (third form))))))
