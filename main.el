(let ((gc-cons-threshold most-positive-fixnum))
(setq sjihs-emacs-config-dir-prefix
      (expand-file-name "~/.emacs-config/"))

(dolist (subdir
	 (directory-files (expand-file-name "~/.emacs.d/elpa/") t))
  (when (and (not (string-suffix-p "." subdir)) (not (string-suffix-p ".." subdir)) (file-directory-p subdir))
    (add-to-list 'load-path subdir)))

;; Always load config-values.el first
(setq sjihs-config-files
      '(config-values.el
	utils.el
	bookmarks.el
	btrfs-computation-helpers.el
	calendar.el
	compilation.el
	c-programming.el
	cursor-movement.el
	debugging.el
	diff.el
	dired.el
	dot.el
	;; emms.el
	ftrace.el
	generic-programming.el
	;; gtags.el
	helm.el
	kernel-build.el
	keyboard-macros.el
	latex.el
	lisp.el
	lsp.el
	magit.el
	mail.el
	Makefile.el
	misc.el
	mode-line.el
	mu4e.el
	notes.el
	org-mode.el
	package.el
	process-mgmt.el
	python.el
	saveplace.el
	server.el
	shell-scripting.el
	text.el
	theme.el
	tramp.el
	version-control.el
	webjump.el
	;; weechat.el
	windows.el
	gdb.el
	perf.el
	calc.el
	xfs.el))

(dolist (sjihs-config-file sjihs-config-files)
  (load
   (concat sjihs-emacs-config-dir-prefix (symbol-name sjihs-config-file))))

(custom-set-variables
 '(custom-file (concat sjihs-emacs-config-dir-prefix "emacs-custom.el")))
(load-file custom-file)
)
