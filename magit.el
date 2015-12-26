(require 'magit)
(global-set-key (kbd "C-c g g") 'magit-status)
(global-set-key (kbd "C-c g b") 'magit-blame-mode)
(setq magit-last-seen-setup-instructions "1.4.0")

(require 'vc-annotate)
(define-key vc-annotate-mode-map (kbd "l")
  '(lambda ()
     (interactive)
     (let ((rev-at-line (vc-annotate-extract-revision-at-line)))
       (if (not rev-at-line)
	   (message "Cannot extract revision number from the current line")
	 (magit-show-commit (car rev-at-line))))))

