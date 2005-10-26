
;;; namelex.el --- minor mode for name lexicon markup

;; Contains key bindings for keys m, f, s, p, o, b, and n
;; n moves to the end of an entry at a name lexicon
;; the other keys insert different tags

;;; $Id$

(define-derived-mode namelex-mode
  text-mode "Name Lexicon mode"
   "Major mode for lexicon markup.
\\{namelex-mode-map}" 
  (setq case-fold-search nil))

(define-key namelex-mode-map "m" '(lambda () (interactive) (insert-markup "mal")))
(define-key namelex-mode-map "f" '(lambda () (interactive) (insert-markup "fem")))
(define-key namelex-mode-map "s" '(lambda () (interactive) (insert-markup "sur")))
(define-key namelex-mode-map "p" '(lambda () (interactive) (insert-markup "plc")))
(define-key namelex-mode-map "r" '(lambda () (interactive) (insert-markup "surplc")))
(define-key namelex-mode-map "o" '(lambda () (interactive) (insert-markup "org")))
(define-key namelex-mode-map "b" '(lambda () (interactive) (insert-markup "obj")))
(define-key namelex-mode-map "n" '(lambda ()(interactive)(search-next-name 1)))

(defun insert-markup (tag)
  "Insert markup tag"
  (interactive "p")
  (insert (concat "-" tag))
  (search-next-name 1))

(defun search-next-name (tag)
  "Move to the next name"
  (interactive "p")
  (if (re-search-forward "[A-Z\-]+ " nil t)
      (skip-chars-backward " ;")
      (goto-char (end-of-line))))
