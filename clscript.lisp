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
          (let* ((end (cl-ppcre:scan "( |\\))" remaining))
                 (atom (subseq remaining 0 end)))
            (setf remaining (subseq remaining end))
            (push atom tokens)))))))
