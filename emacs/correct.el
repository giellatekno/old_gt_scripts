
;;; correct.el --- minor mode for marking correct corpora in Emacs

;; Contains the following functions:
;; - insert-correct-recursive C-c c
;; inserts a <!Correct> tag to the cursor positition if it is at the end of line
;; and if the line does not contain the tag already. Removes <<<. Moves
;; point to the first line of the next cohort.
;; - insert-correct-line C-c x
;; otherwise similar to C-c c but moves point to the next line in the same cohort.
;; - forward-cohort C-c f
;; moves to the next suitable tag position, adding tags if unambiguous.
;; stops to ambiguous cohort.
;; - find-last-correct C-c t
;; if the file is already marked, searches for cohort with no marking.

;;; $Id$

(define-derived-mode correct-corpus-mode
  text-mode "Correct corpus"
   "Major mode for correct corpus.
\\{correct-corpus-mode-map}" 
  (setq case-fold-search nil))

(define-key correct-corpus-mode-map  "\C-cc" 'insert-correct-recursive)
(define-key correct-corpus-mode-map  "\C-cx" 'insert-correct-line)
(define-key correct-corpus-mode-map  "\C-cf" 'forward-cohort)
(define-key correct-corpus-mode-map  "\C-ct" 'find-last-correct)

(defun insert-correct-line (tag)
  (interactive "p")
  (insert-correct 0))

(defun insert-correct-recursive (tag)
  (interactive "p")
  (insert-correct 1))

(defun insert-correct (recursive)
  "Insert correct tag"
  (interactive "p")
  (if (search-backward " <<<" (- (point) 4) t)
	  (delete-char 4))
  (if (not (eolp))
	  (end-of-line))
  (if (not (save-excursion 
			 (search-backward "<Correct!>" (- (point) 10) t)))
	  (insert " <Correct!>")
	(message "Line already contains a correct tag"))
  (if (= recursive 1)
	   (forward-cohort t)
	(forward-line-in-cohort t)))

(defun forward-line-in-cohort (tag)
  "Move to the next line in the same cohort"
  (interactive "p")
  (forward-line 1)
  (if (re-search-forward "\"<" (+ (point) 2) t)
	  (forward-cohort t)
	(end-of-line)))

(defun forward-cohort (tag)
  "Move to first analysis in next cohort"
  (interactive "p")
  (if (re-search-forward ">\"" nil t)
	  (end-of-line 2)
	(goto-char (point-max)))
  (if (and (not (eobp))
		   (not (looking-at "[
]\t")))
	  (insert-correct 1)))

(defun find-last-correct (tag)
  "Move to the last Correct tag or to ambiguous reading"
  (interactive "p")
  (re-search-forward ">\"" nil t)
  (end-of-line 2)
  (while (and (save-excursion (search-backward "<Correct!>" (- (point) 10) t))
			  (not (eobp))
			  (not (looking-at "[
]\t")))
	(re-search-forward ">\"" nil t)
	(end-of-line 2)))

