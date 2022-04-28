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

(global-set-key (kbd "C-c g r") 'helm-git-grep)

(setq magit-revision-insert-related-refs nil)

(defun sjihs-insert-rvb ()
  (interactive)
  (let* ((rvb "Reviewed-by: ")
	 (identity (git-commit-self-ident))
	 (name (nth 0 identity))
	 (email (nth 1 identity)))

    (setq rvb (concat rvb  name " "))
    (setq rvb (concat rvb  "<" email ">" "\n"))
    (insert rvb)))
(global-set-key (kbd "C-c g i r") 'sjihs-insert-rvb)

(defun sjihs-magit-show-commit (commit)
  (interactive "MCommit id: ")
  (magit-show-commit commit))
(global-set-key (kbd "C-c g c") 'sjihs-magit-show-commit)
