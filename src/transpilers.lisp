(in-package #:clscript)


(defvar *transpilers* (make-hash-table :test 'equal))

(defun get-transpiler (form)
  (let* ((first-symbol (first form))
         (symbol-package (package-name (symbol-package first-symbol)))
         (symbol-name (symbol-name first-symbol)))
    (multiple-value-bind (transpiler presentp)
              (gethash (concatenate 'string symbol-package ":" symbol-name) *transpilers*)
            (when presentp transpiler))))

(defmacro define-transpiler (name args &body body)
  `(setf (gethash ,(string-upcase name) *transpilers*)
         #'(lambda ,args
             ,@body)))
