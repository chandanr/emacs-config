(setq sjihs-emacs-config-dir-prefix
      (expand-file-name "~/.emacs-config/"))

(dolist (subdir
	 (directory-files (expand-file-name "~/.emacs.d/elpa/") t))
  (when (file-directory-p subdir)
    (add-to-list 'load-path subdir)))

;; Always load config-values.el first
(setq sjihs-config-files
      '(config-values
	utils
	bookmarks
	btrfs-computation-helpers
	calendar
	compilation
	c-programming
	cursor-movement
	debugging
	diff
	dired
	dot
	emms
	generic-programming
	gtags
	helm
	kernel-build
	latex
	lisp
	magit
	mail
	Makefile
	misc
	mode-line
	notes
	org-mode
	package
	process-mgmt
	python
	saveplace
	server
	shell-scripting
	text
	theme
	tramp
	version-control
	webjump
	weechat
	windows
	math))

(dolist (sjihs-config-file sjihs-config-files)
  (load
   (concat sjihs-emacs-config-dir-prefix (symbol-name sjihs-config-file))))

(custom-set-variables
 '(custom-file (concat sjihs-emacs-config-dir-prefix "emacs-custom.el")))
(load-file custom-file)
