(setq compilation-scroll-output t)

(setq compile-command "make ")
(global-set-key (kbd "C-c c") 'compile)

(defun sjihs-c-compile ()
  (interactive)
  (let* ((filename (buffer-file-name))
	 (compile-command (format "cc -g -Wall %s -o%s"
				  filename (substring filename 0 -2))))
    (compile compile-command)))
(global-set-key (kbd "<f9>") 'sjihs-c-compile)

(setq compilation-ask-about-save nil)
