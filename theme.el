(setq custom-theme-load-path
      (cons (expand-file-name "~/.emacs-config/") custom-theme-load-path))

(when (eq window-system 'x)
  (load-theme 'Redhat t))

(set-face-attribute 'default nil :family "Monospace" :height 90)

(defun sjihs-disable-bold-font ()
  (interactive)
  (mapc
   (lambda (face)
     (set-face-attribute face nil :weight 'normal))
   (face-list)))
