
;;; Correct-corpus-mode
; Contains the following functions:
; - correct-corpus-insert-correct \C-c
; inserts a <!Correct> tag to the cursor positition if it is at the end of line
; and if the line does not contain the tag already. Removes <<<.
; - forward-cohort \C-f
; moves to the next suitable tag position, adding tags if unambiguous.
; stops to ambiguous cohort.
; - find-last-correct \C-t
; if the file is already marked, searches for an empty reading.
;
; $Id$

(define-derived-mode correct-corpus-mode
  text-mode "Correct corpus"
   "Major mode for correct corpus.
\\{correct-corpus-mode-map}" 
  (setq case-fold-search nil))

(define-key correct-corpus-mode-map
  "\C-cc" 'correct-corpus-insert-correct)

(defun correct-corpus-insert-correct (tag)
  "Insert correct tag"
  (interactive "p")
  (if (search-backward " <<<" (- (point) 4) t)
	  (delete-char 4))
  (if (not (eolp))
	  (message "Insert tag only at the end of line")
	(if (not (save-excursion 
			   (search-backward "<!Correct>" (- (point) 10) t)))
		(insert-correct 1)
	  (message "Already contains a correct tag."))))

(defun insert-correct (tag)
  "Insert tag"
  (interactive "p")
  (insert " <!Correct>")
  (correct-corpus-forward-cohort 1))

(define-key correct-corpus-mode-map
  "\C-cf" 'correct-corpus-forward-cohort)

(defun correct-corpus-forward-cohort (tag)
  "Move to first analysis in next cohort"
  (interactive "p")
  (if (re-search-forward ">\"" nil t)
	  (end-of-line 2)
	(goto-char (point-max)))
  (if (and (not (eobp))
		   (not (looking-at "[
]\t")))
	  (correct-corpus-insert-correct 1)))

(define-key correct-corpus-mode-map
  "\C-ct" 'correct-corpus-find-last-correct)

(defun correct-corpus-find-last-correct (tag)
  "Move to the last Correct tag or to ambiguous reading"
  (interactive "p")
  (re-search-forward ">\"" nil t)
  (end-of-line 2)
  (while (and (save-excursion (search-backward "<!Correct>" (- (point) 10) t))
			  (not (eobp))
			  (not (looking-at "[
]\t")))
	(re-search-forward ">\"" nil t)
	(end-of-line 2)))

