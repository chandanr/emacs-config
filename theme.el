(setq custom-theme-load-path
      (cons (expand-file-name "~/.emacs-config/") custom-theme-load-path))

(when (eq window-system 'x)
  (load-theme 'tango-dark t))

(set-face-attribute 'default nil :family "Source code pro" :height 180 :foreground "grey")

(defun sjihs-disable-bold-font ()
  (interactive)
  (mapc
   (lambda (face)
     (set-face-attribute face nil :weight 'normal))
   (face-list)))

(global-hl-line-mode)
