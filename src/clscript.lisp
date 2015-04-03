(in-package #:clscript)


(defun transpile (code)
  (let ((forms (mapcar #'(lambda (form)
                           (sb-cltl2:macroexpand-all (read-from-string form)))
                       (get-forms code))))
    (mapcar #'lisp-to-js forms)))

(defun lisp-to-js (form)
  form)
