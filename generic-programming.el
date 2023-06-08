;;; Highlight lines longer than 80 columns
(setq whitespace-line-column 80
      show-paren-mode t)

(global-set-key (kbd "RET") 'newline-and-indent)

(show-paren-mode t)

(custom-set-variables '(show-paren-style 'parenthesis t))

(global-set-key
 (kbd "<f1>")
 (lambda () (interactive) (manual-entry (current-word))))


(defun sjihs-build-gtags (sjihs-dir-name)
  (interactive "DSource directory: \n" )
  (compile (format "gtags %s" sjihs-dir-name)))
(global-set-key (kbd "C-c t") 'sjihs-build-gtags)
