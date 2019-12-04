;;; Dired settings
;; (add-hook 'dired-mode-hook '(lambda () (auto-revert-mode t)))
(put 'dired-find-alternate-file 'disabled nil)
(setq dired-isearch-filenames t
      dired-listing-switches "-lh --group-directories-first"
      list-directory-brief-switches "-CFh"
      list-directory-verbose-switches "-lh"
      dired-recursive-copies 'always
      dired-recursive-deletes 'top)

(require 'dired)
;;; Miscellaneous keybindings
(define-key dired-mode-map (kbd "C-c C-f") 'find-name-dired)

(defun sjihs-open-in-external-app ()
  (interactive)
  (let ((do-it nil)
	(file-path nil)
	(file-list
	 (cond
	  ((string-equal major-mode "dired-mode") (dired-get-marked-files))
	  (t (list (buffer-file-name))))))
    (setq do-it (if (<= (length file-list) 1)
		    t
		  (y-or-n-p "Open more than 5 files?")))
    (when do-it
      (mapc (lambda (file-path)
	      (start-process-shell-command
	       file-path "sjihs async processes"
	       (format "xdg-open \"%s\"" file-path)))
	    file-list))))
(define-key dired-mode-map (kbd "<f12>") 'sjihs-open-in-external-app)

