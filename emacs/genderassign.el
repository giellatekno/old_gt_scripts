
;;; genderassign.el --- minor mode for gender markup

;; Contains key bindings for keys m, f, n, x
;; n moves to the end of an entry at a name lexicon
;; the other keys insert different tags

;; Quasicode:
;; await keypress v
;; go to next gen="xxx"
;; await keypress n, m, f
;; replace with gen="n" etc.
;; go to next gen="xxx"
;; xxx er i bruk også for decl men det kan eg endre
;; ok - men det er sikkert mogleg å avgrensa til gen="xxx"
;; enklast å ender decl="yyy"
;;; $Id: namelex.el 4997 2005-11-11 07:27:38Z trond $

(define-derived-mode genderassign-mode
  text-mode "Assign Gender mode"
   "Major mode for Gender assignment.
\\{genderassign-mode-map}" 
  (setq case-fold-search nil))

(define-key namelex-mode-map "m" '(lambda () (interactive) (insert-markup "m")))
(define-key namelex-mode-map "f" '(lambda () (interactive) (insert-markup "f")))
(define-key namelex-mode-map "n" '(lambda () (interactive) (insert-markup "n")))
(define-key namelex-mode-map "x" '(lambda () (interactive) (search-next-xxx "1")))

;; det ser ut til at insert-markup ikkje trengst - eg veit for lite - eg ville ha venta
;; originale var
;; sök BERN ; erstatt BERN-plc ;
;; OK - men vi vil ha noko liknande: søk gen="xxx", erstatt gen="m/f/n"

(defun insert-markup (tag)
  "Insert markup tag"
  (interactive "p")
  (insert (concat "-" tag))
  (search-next-xxx 1))

(defun search-next-xxx (tag)
  "Move to the next xxx instance"
  (interactive "p")
  (if (re-search-forward "xxx" nil t)
      (goto-char (end-of-line))))
