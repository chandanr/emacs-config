(setq sjihs-kernel-conf-variables
      '(sjihs-browser-program))

(dolist (sjihs-var
	 sjihs-kernel-conf-variables)
  (when (not (boundp sjihs-var))
    (error "%s: %s variable not set" load-file-name (symbol-name sjihs-var))))

(add-hook 'after-save-hook
	  'executable-make-buffer-file-executable-if-script-p)

(mouse-avoidance-mode 'animate)
(scroll-bar-mode -1)
(menu-bar-mode -1)
(tool-bar-mode -1)
(pending-delete-mode t)

(fset 'yes-or-no-p 'y-or-n-p)
(fset 'grep 'rgrep)

(set-default 'truncate-lines t)

(setq inhibit-startup-message t
      inhibit-startup-screen t
      frame-title-format '("Emacs-" emacs-version " %b")
      x-select-enable-clipboard t
      x-select-enable-primary t
      scroll-bar-mode nil
      require-final-newline t
      global-font-lock-mode t
      font-lock-maximum-decoration t
      blink-cursor-mode t
      backup-directory-alist '((".*" . "~/.emacs.d/"))
      browse-url-browser-function 'browse-url-generic
      browse-url-generic-program sjihs-browser-program
      grep-command "grep -RniI "
      find-name-arg "-iname")

(global-set-key (kbd "<f4>") 'rename-buffer)

(defun sjihs-goto-line-with-feedback ()
  (interactive)
  (unwind-protect
      (progn
	(linum-mode 1)
	(call-interactively 'goto-line))
    (linum-mode -1)))
(global-set-key [remap goto-line] 'sjihs-goto-line-with-feedback)

(defun sjihs-dos-to-unix (file-path)
  (interactive "fFile name: ")
  (save-excursion
    (let (dos-buffer)
      (setq dos-buffer (find-file file-path))
      (set-buffer-file-coding-system 'unix)
      (save-buffer)
      (kill-buffer dos-buffer))))

(defun sjihs-unix-to-dos (file-path)
  (interactive "fFile name: ")
  (save-excursion
    (let (unix-buffer)
      (setq unix-buffer (find-file file-path))
      (set-buffer-file-coding-system 'dos)
      (save-buffer)
      (kill-buffer unix-buffer))))
