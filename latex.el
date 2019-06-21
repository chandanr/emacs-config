;; latex
(setq TeX-auto-save t)
(setq TeX-parse-self t)
;; (setq-default TeX-master nil)
(local-set-key (kbd "RET") 'reindent-then-newline-and-indent)

(add-hook 'LaTeX-mode-hook 'visual-line-mode)
(add-hook 'LaTeX-mode-hook 'flyspell-mode)
(add-hook 'LaTeX-mode-hook 'LaTeX-math-mode)

(add-hook 'LaTeX-mode-hook 'turn-on-reftex)

(defun sjihs-latex-build-on-save ()
  (add-hook
   'after-save-hook
   (lambda ()
     (save-window-excursion
       (TeX-command-menu "LaTeX")))))
(add-hook 'LaTeX-mode-hook 'sjihs-latex-build-on-save)

(setq reftex-plug-into-AUCTeX t)
(setq TeX-PDF-mode t)
(setq latex-run-command "pdflatex")
(setq-default TeX-engine 'xetex)

;; Auctex
(require 'latex)
(TeX-PDF-mode)
(defun pdfokular ()
  (add-to-list 'TeX-output-view-style
	       '("^pdf$" "." "okular %o %(outpage)")))
(setq TeX-view-program-list '(("Okular" "okular %o")))
(setq TeX-view-program-selection '((output-pdf "Okular")))
(add-hook 'LaTeX-mode-hook 'pdfokular  t) ; AUCTeX LaTeX mode
