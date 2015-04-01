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
         ((= (length remaining) 0) (return-from tokenize tokens))

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

(defun read-from-tokens (tokens)
  (let ((token (vector-pop tokens)))
    (cond
      ((string= token +token-left-paren+)
       (let ((ast nil))
         (loop
            :until (string= (elt tokens (- (length tokens) 1)) +token-right-paren+)
            :do (push (read-from-tokens tokens) ast))
         (vector-pop tokens) ; pop off ")"
         (reverse ast)))
      (t token))))

(defun parse (code)
  (read-from-tokens (list-to-vector (tokenize code))))

(defun list-to-vector (list)
  "Converts a list to a fill-pointer vector
Unfortunately, (coerce list 'vector) doesn't do that."
  (let ((vector (make-array 0 :fill-pointer 0)))
    (loop
       :for item in list
       :do (vector-push-extend item vector))
    vector))
