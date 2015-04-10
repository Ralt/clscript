(in-package #:clscript)


(defun main (args)
  (declare (ignore args))
  (format t "~A" (transpile (read-stdin))))

(defun read-stdin ()
  (with-output-to-string (ret)
    (with-open-stream (s *standard-input*)
      (loop
         :for line = (read-line s nil)
         :while line
         :do (write-string line ret)))
    ret))

(defun transpile (code)
  (format
   nil
   "~{~A~%~}"
   (alexandria:flatten
    (mapcar #'transpile-form
            (mapcar #'(lambda (form)
                        (sb-cltl2:macroexpand-all (read-from-string form)))
                    (get-forms code))))))

(defun transpile-form (form)
  ;; when it's not a list, then just return it.
  (unless (eq (type-of form) 'cons)
    (return-from transpile-form (transpile-atom form)))
  (let ((transpiler (get-transpiler form)))
    (if transpiler
        (funcall transpiler form)
        (default-transpiler form))))
