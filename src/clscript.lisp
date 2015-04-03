(in-package #:clscript)


(defconstant +token-left-paren+ "(")
(defconstant +token-right-paren+ ")")
(defconstant +token-double-quote+ "\"")
; " fix emacs syntax highlighting.

(defun tokenize (string)
  (let ((remaining string)
        (tokens nil))
    (loop
       :do
       (cond
         ((= (length remaining) 0) (return-from tokenize (reverse tokens)))

         ;; new expression
         ((string= +token-left-paren+ (subseq remaining 0 1))
          (let ((character (subseq remaining 0 1)))
            (setf remaining (subseq remaining 1))
            (push character tokens)))

         ;; close expression
         ((string= +token-right-paren+ (subseq remaining 0 1))
          (let ((character (subseq remaining 0 1)))
            (setf remaining (subseq remaining 1))
            (push character tokens)))

         ;; literal string
         ((string= +token-double-quote+ (subseq remaining 0 1))
          (let* ((end (cl-ppcre:scan "\"" (subseq remaining 1)))
                 (str (subseq remaining 0 (+ end 2)))) ; " fix emacs
            (setf remaining (subseq remaining (+ end 2)))
            (push str tokens)))

         ;; space
         ((string= " " (subseq remaining 0 1))
          (setf remaining (subseq remaining 1))) ; just ignore spaces

         ;; atom
         (t
          (let* ((end (cl-ppcre:scan "( |\\)|$)" remaining))
                 (atom (subseq remaining 0 end)))
            (setf remaining (subseq remaining end))
            (push atom tokens)))))))

(defun list-to-vector (list)
  "Converts a list to a fill-pointer vector
Unfortunately, (coerce list 'vector) doesn't do that."
  (let ((vector (make-array 0 :fill-pointer 0)))
    (loop
       :for item in list
       :do (vector-push-extend item vector))
    vector))

(defmacro get-last (list)
  `(elt ,list (- (length ,list) 1)))

(defun get-forms (code)
  (let ((tokens (tokenize code))
        (forms nil)
        (counter 0))
    (loop
       :for token in tokens
       :do (cond ((string= token +token-left-paren+)
                  (progn
                    (incf counter)
                    (if (= counter 1)
                        (setf forms (append forms (list token)))
                        (setf (get-last forms)
                              (concatenate 'string (get-last forms) " " token)))))
                 ((string= token +token-right-paren+)
                  (progn
                    (decf counter)
                    (setf (get-last forms)
                          (concatenate 'string (get-last forms) " " token))))
                 (t (progn
                      (setf (get-last forms)
                            (concatenate 'string (get-last forms) " " token))))))
    forms))

(defun transpile (code)
  (let ((forms (mapcar #'(lambda (form)
                           (sb-cltl2:macroexpand-all (read-from-string form)))
                       (get-forms code))))
    (mapcar #'lisp-to-js forms)))

(defun lisp-to-js (forms)
  forms)
