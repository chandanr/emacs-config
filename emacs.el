;; Configuration variables
(setq
 ;; kernel build configuration values
 sjihs-linux-src-dir (expand-file-name "~/code/repos/linux/")
 sjihs-linux-build-dir (expand-file-name "/home/chandan/junk/build/linux/")
 sjihs-linux-image-relative-path "bzImage"
 sjihs-vmlinux-relative-path "vmlinux"
 sjihs-linux-configs-dir (expand-file-name "~/kernel-configs/")
 sjihs-linux-config-symlink-suffix "kernel-config"
 sjihs-linux-config-file
 (expand-file-name (format "%s/%s"
			   (expand-file-name "~/kernel-configs/")
			   sjihs-linux-config-symlink-suffix))

 sjihs-vmlinux-install-location "/boot/vmlinuz-mod"
 sjihs-build-target "bzImage"

 ;; ftrace sysfs entry
 sjihs-ftrace-sysfs-dir "/sys/kernel/debug/tracing/"

 ;; Perf configuration values
 sjihs-perf-log-file (expand-file-name "~/junk/perf.log")
 sjihs-perf-history (expand-file-name "~/.perf-history")

 ;; Gtags
 sjihs-gtags-path "/usr/share/emacs/site-lisp/gtags.elc"

 ;; Org mode
 sjihs-gtd-org-directory "~/google-drive/documents/gtd"
 sjihs-gtd-org-agenda-files
 '("~/google-drive/documents/gtd/gtd.txt"
   "~/google-drive/documents/gtd/gtd.txt_archive")

 ;; Guest/Host
 sjihs-guest nil

 ;; xfs
 sjihs-xfsprogs-prebuilt-dir "/opt/xfsprogs-build/"
 sjihs-xfsprogs-prebuilt-symlink-prefix "xfsprogs-build"
 sjihs-xfstests-dir (expand-file-name "~/repos/xfstests-dev/common")

 ;; Misc
 sjihs-browser-program "firefox"
 sjihs-patch-review-directory "/shared-documents/patch-reviews/"
 sjihs-nr-cpus 8
 load-prefer-newer t
 sjihs-backup-directory "/root/junk/emacs-backup-dir/")

;; Mode independent default faces to use
(set-face-attribute 'default nil
		    :foreground "color-252")

(require 'package)
(add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/"))
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(when (not (package-installed-p 'use-package))
  (package-refresh-contents)
  (package-install 'use-package))

(use-package s
  :ensure t)

(use-package helm
  :defer nil
  :ensure t)

(use-package helm-mode
  :defer nil
  :config
  (setq
   ;; Open helm buffer inside current window, not occupy whole other window
   helm-split-window-in-side-p t
   ;; Move to end or beginning of source when reaching top or bottom of source.
   helm-move-to-line-cycle-in-source t
   ;; Search for library in `require' and `declare-function' sexp.
   helm-ff-search-library-in-sexp t
   ;; Scroll 8 lines other window using M-<next>/M-<prior>
   helm-scroll-amount 8
   helm-ff-file-name-history-use-recentf t
   helm-buffers-fuzzy-matching t
   helm-recentf-fuzzy-match t)
  (helm-mode 1)
  (set-face-attribute 'helm-selection nil
		      :background "color-28")

  :bind (("C-c h" . helm-command-prefix)
	 ("C-c h o" . helm-occur)
	 ("M-x" . helm-M-x)
	 ("M-y" . helm-show-kill-ring)
	 ("C-x b" . helm-mini)
	 ("C-x C-f" . helm-find-files)
	 (:map helm-map
	       ("<tab>" . helm-execute-persistent-action)
	       ("C-i" . helm-execute-persistent-action)
	       ("C-z" . helm-select-action))))

(use-package helm-xref
  :demand t
  :after (:all helm helm-mode)
  :bind (:map prog-mode-map
	      ("M-." . xref-find-definitions)
	      ("C-M-." . xref-find-apropos)
	      ("M-," . xref-find-references)
	      ("M-*" . xref-pop-marker-stack)))

(use-package helm-git-grep
  :defer nil
  :after (:all helm-mode)
  :ensure t)

(use-package company
  :ensure t)

(use-package lsp-mode
  :ensure t
  :after company
  :config
  (setq lsp-clients-clangd-args '("-j=4" "-log=error" "--background-index")
	lsp-diagnostics-provider :none
	lsp-enable-snippet nil)

  (use-package lsp-headerline
    :config
    (set-face-attribute 'lsp-headerline-breadcrumb-path-face nil
			:inherit 'black)
    (set-face-attribute 'lsp-headerline-breadcrumb-separator-face nil
			:inherit 'black :height 0.8)
    (set-face-attribute 'lsp-headerline-breadcrumb-symbols-face nil
			:weight 'extrabold :foreground "color-124")))

(use-package lsp-ui
  :ensure t
  :after lsp-mode
  :config
  :hook ((lsp-mode . lsp-ui-mode)))

(use-package lsp-ui-doc
  :after lsp-ui
  :config
  (setq lsp-ui-doc-include-signature t
	lsp-ui-doc-delay 1.5
	lsp-ui-sideline-delay 1.5))

(use-package company-capf
  :requires company
  :after lsp-mode
  :config
  (push 'company-capf company-backends)
  (setq company-minimum-prefix-length 1
	company-idle-delay 0.0))

;; cc-mode configuration
(use-package cc-mode
  :requires subr-x
  :after (:all lsp-mode helm-xref)
  :config
  (defun sjihs-get-nth-line (line-number)
    (save-excursion
      (goto-line line-number)
      (buffer-substring-no-properties
       (line-beginning-position)
       (line-end-position))))

  (defun sjihs-get-pos-column-number (pos)
    (save-excursion
      (goto-char pos)
      (current-column)))

  (defun sjihs-align-below-condition-p (cond-stmt)
    (let ((align t))
      (when (string-match ".+\\(==\\|!=\\|\s&\\|\s^\\|\s|\\)\s*$" cond-stmt)
	(setq align nil))
      align))

  (defun sjihs-compute-cond-stmt-indentation (anchor1 anchor2)
    (let (column1 column2 offset stmt)
      ;; First condition of if/while statement consists of a function
      ;; call.
      ;; We ignore the 2nd c-syntactic element
      (if (= (length c-syntactic-context) 2)
	  (progn
	    (setq offset nil)
	    (when (eq c-syntactic-element (nth 0 c-syntactic-context))
	      (setq column1 (sjihs-get-pos-column-number anchor1))
	      (setq offset
		    (vector (+ column1 (* 2 c-basic-offset))))))

	(setq column1 (sjihs-get-pos-column-number anchor1))
	(setq column2 (sjihs-get-pos-column-number anchor2))
	(setq stmt (sjihs-get-nth-line (1- (line-number-at-pos))))
	(setq stmt (string-trim-right stmt))

	(if (sjihs-align-below-condition-p stmt)
	    (setq offset
		  (vector (1+ column2)))
	  (setq offset
		(vector (+ column1 (* 2 c-basic-offset))))))
      offset))

  (defun sjihs-compute-regular-stmt-indentation (anchor1)
    (let (column1 offset)
      (setq column1 (sjihs-get-pos-column-number anchor1))

      (when (% column1 c-basic-offset)
	(setq column1 (/ column1 c-basic-offset))
	(setq column1 (* column1 c-basic-offset)))

      (setq offset
	    (vector (+ column1 (* 2 c-basic-offset))))

      offset))

  ;; c-echo-syntactic-information-p
  (defun sjihs-linux-set-arglist-cont-nonempty (ignored)
    (let ((anchor1 (c-langelem-pos c-syntactic-element))
	  (anchor2 (c-langelem-2nd-pos c-syntactic-element))
	  offset stmt)

      (setq stmt
	    (sjihs-get-nth-line (line-number-at-pos anchor1)))

      (if (string-match "[\s\t]+\\(if\\|while\\)\s*(.+" stmt)
	  (setq offset (sjihs-compute-cond-stmt-indentation anchor1 anchor2))

	(setq offset (sjihs-compute-regular-stmt-indentation anchor1)))

      offset))
  (c-add-style
   "xfs-linux"
   '("linux" (c-offsets-alist
	      (arglist-cont-nonempty . (first sjihs-linux-set-arglist-cont-nonempty)))))


  :hook ((c-mode-common . (lambda () (c-toggle-hungry-state)))
  	 (c-mode-common . (lambda () (local-set-key  (kbd "C-c o") 'ff-find-other-file)))
  	 (c-mode-common . (lambda ()
			    (font-lock-add-keywords
			     nil
			     '(("\\<\\(FIXME\\|TODO\\|BUG\\|chandan\\):"
				1 font-lock-warning-face t)))))
  	 (c-mode-common . lsp)
  	 (c++-mode . lsp)
  	 (c-mode . (lambda ()
		     (setq c-basic-offset 8
			   indent-tabs-mode t
			   fill-column 80
			   comment-style 'extra-line
			   ;; c-echo-syntactic-information-p t
			   )
		     (c-set-style "xfs-linux")))
  	 (c-mode . (lambda()
		     (setq whitespace-style
			   '(face trailing space-before-tab
				  space-after-tab indentation))
		     (whitespace-mode))))

  :bind (:map c-mode-map
	      ("M-/" . complete-tag)
	      ("M-a" . c-beginning-of-defun)
	      ("M-e" . c-end-of-defun)))

(use-package magit
  :ensure t
  :requires s
  :after (:all s helm)
  :config
  (use-package vc-annotate
    :config
    (defun sjihs-show-revision ()
      (interactive)
      (let ((rev-at-line (vc-annotate-extract-revision-at-line)))
  	(if (not rev-at-line)
  	    (message "Cannot extract revision number from the current line")
  	  (magit-show-commit (car rev-at-line)))))

    (setq vc-git-diff-switches "-b"
  	  vc-diff-switches "-b")
    :bind
    (:map vc-annotate-mode-map
  	  ("l" . sjihs-show-revision)))

  (set-face-attribute 'magit-diff-added nil
		      :background "#335533" :foreground "color-188")
  (set-face-attribute 'magit-diff-added-highlight nil
		      :background "color-23" :foreground "grey")
  (set-face-attribute 'magit-hash nil
		      :foreground "blue")
  (set-face-attribute 'magit-header-line nil
		      :foreground "black")
  (set-face-attribute 'magit-branch-remote nil
		      :foreground "green")

  (defun sjihs-insert-tag (tag)
    (let* ((identity (git-commit-self-ident))
	   (name (nth 0 identity))
	   (email (nth 1 identity))
	   (tagname))
      (cond
       ((string= tag "acb")
	(setq tagname "Acked-by: "))
       ((string= tag "rvb")
	(setq tagname "Reviewed-by: "))
       ((string= tag "ttb")
	(setq tagname "Tested-by: ")))

      (setq tagname (concat tagname  name " "))
      (setq tagname (concat tagname  "<" email ">" "\n"))
      (insert tagname)))

  (defun sjihs-insert-acb ()
    (interactive)
    (sjihs-insert-tag "acb"))

  (defun sjihs-insert-rvb ()
    (interactive)
    (sjihs-insert-tag "rvb"))

  (defun sjihs-insert-ttb ()
    (interactive)
    (sjihs-insert-tag "ttb"))

  (defun sjihs-magit-show-commit (commit)
    (interactive "MCommit id: ")
    (magit-show-commit commit))

  (defun sjihs-magit-show-short-commit (commit)
    (interactive "MCommit id: ")
    (let (short-commit)
      (setq short-commit
  	    (s-trim
  	     (shell-command-to-string
  	      (concat "git rev-parse --short " commit))))
      (message "%s" short-commit)
      (kill-new short-commit)))

  (setq magit-last-seen-setup-instructions "1.4.0"
  	magit-revision-insert-related-refs nil)

  (remove-hook 'magit-refs-sections-hook 'magit-insert-tags)
  
  :bind
  (("C-c g g" . magit-status)
   ("C-c g b" . magit-blame-mode)
   ("C-c g r" . helm-git-grep)
   ("C-c g i a" . sjihs-insert-acb)
   ("C-c g i r" . sjihs-insert-rvb)
   ("C-c g i t" . sjihs-insert-ttb)
   ("C-c g c" . sjihs-magit-show-commit)
   ("C-c g s" . sjihs-magit-show-short-commit)))

(use-package make-mode
  :hook ((makefile-mode . (lambda() (setq show-trailing-whitespace t)))))

(use-package calc-mode
  :init
  (eval-after-load "calc-bin"
    '(calc-word-size 128))

  (eval-after-load "calc-units"
    (progn
      (setq math-additional-units
	    '((GiB "1024 * MiB" "Giga Byte")
	      (MiB "1024 * KiB" "Mega Byte")
	      (KiB "1024 * B" "Kilo Byte")
	      (B nil "Byte")
	      (Gib "1024 * Mib" "Giga Bit")
	      (Mib "1024 * Kib" "Mega Bit")
	      (Kib "1024 * b" "Kilo Bit")
	      (b "B / 8" "Bit")))
      (setq math-units-table nil))))

(use-package calendar
  :config
  (setq calendar-week-start-day 1)
  (setq calendar-mark-holidays-flag t)
  (setq holiday-general-holidays nil
	holiday-solar-holidays nil
	holiday-bahai-holidays nil
	holiday-christian-holidays nil
	holiday-hebrew-holidays nil
	holiday-islamic-holidays nil
	holiday-oriental-holidays nil
	holiday-other-holidays nil)

  (setq calendar-latitude 12.976750
	calendar-longitude 77.575279)

  (setq holiday-other-holidays
	'((holiday-fixed 1 26 "Republic day")
	  (holiday-fixed 3 22 "Ugadi")
	  (holiday-fixed 5 1 "May day")
	  (holiday-fixed 6 29 "Bakrid")
	  (holiday-fixed 8 15 "Independence day")
	  (holiday-fixed 9 18 "Ganesh Chaturthi")
	  (holiday-fixed 10 2 "Gandhi Jayanti")
	  (holiday-fixed 10 24 "Dussera")
	  (holiday-fixed 11 1 "Karnataka rajyotsava")
	  (holiday-fixed 11 13 "Deepavali")
	  (holiday-fixed 12 25 "Christmas"))))

(use-package compile
  :config
  (setq compilation-scroll-output t
	compile-command "make "
	compilation-ask-about-save nil)
  (defun sjihs-c-compile ()
    (interactive)
    (let* ((filename (buffer-file-name))
	   (compile-command (format "cc -g -Wall %s -o%s"
				    filename (substring filename 0 -2))))
      (compile compile-command)))
  :bind (("<f9>" . sjihs-c-compile)))

(use-package gud-mode
  :config
  (gud-tooltip-mode)
  (setq gdb-create-source-file-list nil
	gdb-use-separate-io-buffer nil
	gdb-many-windows t
	gdb-speedbar-auto-raise t
	gdb-non-stop-setting nil)
  :bind (:map gud-mode-map
	      ("C-x C-a C-z" . gud-pstar)
	      ("C-c g d" . gdb-display-disassembly-buffer)))

(use-package diff-mode
  :config
  (setq ediff-split-window-function 'split-window-vertically
	ediff-window-setup-function 'ediff-setup-windows-plain)
  :hook ((diff-mode . (lambda ()
			(save-excursion
			  (goto-char (point-min))
			  (while (not (eobp))
			    (diff-hunk-next)))))))

(use-package dired
  :defer nil
  :config
  (defun sjihs-open-in-external-app ()
    (interactive)
    (let ((do-it nil)
	  (file-path nil)
	  (file-list
	   (cond
	    ((string-equal major-mode "dired-mode") (dired-get-marked-files))
	    (t (list (buffer-file-name))))))
      (setq do-it (if (<= (length file-list) 5)
		      t
		    (y-or-n-p "Open more than 5 files?")))
      (when do-it
	(mapc (lambda (file-path)
		(start-process-shell-command
		 file-path "sjihs async processes"
		 (format "xdg-open \"%s\"" file-path)))
	      file-list))))

  (setq dired-isearch-filenames t
	dired-listing-switches "-lah --group-directories-first"
	list-directory-brief-switches "-CFh"
	list-directory-verbose-switches "-lh"
	dired-recursive-copies 'always
	dired-recursive-deletes 'top)

  :bind (:map dired-mode-map
	      ("C-c C-f" . find-name-dired)
	      ("<f12>" . sjihs-open-in-external-app)
	      ("h" . dired-omit-mode)))

(use-package dired-x
  :demand t
  :hook ((dired-load . (lambda () (load "dired-x")))
	 (dired-mode . (lambda ()
			 (setq dired-omit-files
			       (concat dired-omit-files "\\|^[.]+"))
			 (dired-omit-mode 1)))))

(use-package dot
  :config
  (defun sjihs-compile-on-save ()
    (add-hook
     'after-save-hook
     (lambda ()
       (save-window-excursion
	 (compile compile-command))) t t))
  (setq graphviz-dot-preview-extension "png")

  :hook ((graphviz-dot-mode . sjihs-compile-on-save)))

(use-package ediff
  :config
  (set-face-attribute 'ediff-current-diff-A nil
		      :background "color-61")
  (set-face-attribute 'ediff-current-diff-B nil
		      :background "color-61")
  (set-face-attribute 'ediff-fine-diff-A nil
		      :background "color-124")
  (set-face-attribute 'ediff-fine-diff-B nil
		      :background "color-23")
  (set-face-attribute 'ediff-even-diff-A nil
		      :background "color-242")
  (set-face-attribute 'ediff-even-diff-B nil
		      :background "color-242")
  (set-face-attribute 'ediff-odd-diff-A nil
		      :background "color-242")
  (set-face-attribute 'ediff-odd-diff-B nil
		      :background "color-242"))

(use-package tex
  :ensure auctex
  :config
  (setq TeX-auto-save t
	TeX-parse-self t
	reftex-plug-into-AUCTeX t
	TeX-PDF-mode t
	latex-run-command "pdflatex"
	TeX-engine 'xetex)
  :hook ((LaTeX-mode . visual-line-mode)
	 (LaTeX-mode . flyspell-mode)
	 (LaTeX-mode . LaTeX-math-mode)
	 (LaTeX-mode . turn-on-reftex)))

(use-package lisp-mode
  :hook ((lisp-mode . (lambda ()
			(local-set-key (kbd "RET") 'newline-and-indent)
			(setq fill-column 80
			      whitespace-style
			      '(face trailing space-before-tab
				     space-after-tab indentation))
			(whitespace-mode)))))

(use-package elisp-mode
  :hook ((emacs-lisp-mode . (lambda () (eldoc-mode 1)))
	 (emacs-lisp-mode . (lambda ()
			      (local-set-key (kbd "RET") 'newline-and-indent)))
	 (emacs-lisp-mode . (lambda ()
	 		      (setq fill-column 80
	 			    whitespace-style '(face trailing space-before-tab
	 						    space-after-tab indentation))
			      (whitespace-mode)))))

(use-package org
  :config
  (add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
  (setq org-export-with-sub-superscripts nil
	org-hide-leading-stars t
	org-clock-persist t
	org-startup-align-all-tables t
	org-enforce-todo-dependencies t
	org-agenda-dim-blocked-tasks t
	org-hierarchical-todo-statistics nil
	org-agenda-skip-scheduled-if-done t
	org-clock-persist 'history
	org-agenda-span 'day
	org-return-follows-link t
	org-log-into-drawer t
	org-directory sjihs-gtd-org-directory
	org-agenda-files sjihs-gtd-org-agenda-files
	org-export-htmlize-output-type 'css
	org-clock-idle-time 10
	org-duration-format 'h:mm
	org-clock-persist 'history)
  (org-clock-persistence-insinuate)
  (setq org-stuck-projects
	'("+LEVEL=2/-DONE-SOMEDAY_MAYBE"
	  nil ;("NEXTACTION" "PROJECTS" "WAITING_FOR" "DELEGATED")
	  nil
	  "\\(SCHEDULED\\|DEADLINE\\)"))
  (setq org-agenda-custom-commands
	'(("W" "Biweekly review"
	   agenda ""
	   ((org-agenda-tag-filter-preset '("+WORK"))
	    (org-agenda-start-on-weekday nil)
	    (org-agenda-time-grid nil)
	    (org-agenda-skip-scheduled-if-done nil)
	    (org-agenda-include-diary nil)
	    (org-agenda-log-mode-items '(state))
	    (org-agenda-files sjihs-gtd-org-agenda-files)
	    (org-agenda-span 14)
	    (org-agenda-start-day "-14d")
	    (org-agenda-archives-mode t)
	    (org-agenda-show-log nil)
	    (org-agenda-start-with-log-mode nil)
	    (org-agenda-overriding-header "Biweekly work review")))
	  ("w" tags-todo
	   "+WORK&+TODO={NEXTACTION\\|WAITING_FOR}&+SCHEDULED<=\"<today>\"")
	  ("h" tags-todo
	   "+HOME&+TODO={NEXTACTION\\|WAITING_FOR}&+SCHEDULED<=\"<today>\"")
	  ("o" tags-todo
	   "+OUTSIDE&+TODO={NEXTACTION\\|WAITING_FOR}&+SCHEDULED<=\"<today>\"")))
  :hook ((org-mode . turn-on-auto-fill))
  :bind
  (("\C-cl" . org-store-link)
   ("\C-cc" . org-capture)
   ("\C-ca" . org-agenda)
   ("\C-cb" . org-iswitchb)
   (:map org-mode-map
	 ("C-c ," . org-insert-structure-template))))

(use-package python
  :config
  (defun lookup-python-doc ()
    (interactive)
    (let (search-url keyword)
      (setq keyword
	    (if (region-active-p)
		(buffer-substring-no-properties (region-beginning) (region-end))
	      (thing-at-point 'symbol)))
      (message "%s"
	       (setq search-url
		     (format
		      "file:///usr/share/doc/python-docs-2.7.5/html/search.html?q=%s&check_keywords=yes&area=default"
		      keyword)))
      (browse-url search-url)))

  (defun sjihs-python-setup-indent ()
    (let ((filename (buffer-file-name (current-buffer))))
      (setq filename (file-name-nondirectory filename))
      (if (string-match "^perf-script.*\\.py$" filename)
	  (setq indent-tabs-mode t
		tabs-width 8
		python-indent-offset 8)
	  (setq indent-tabs-mode nil
		tabs-width 4
		python-indent-offset 4))))

  (setq python-shell-interpreter "python3")
  :hook ((python-mode . whitespace-mode)
	 (python-mode . (lambda () (setq forward-sexp-function nil)))
	 (python-mode . sjihs-python-setup-indent))
  :bind (:map python-mode-map
	      ("<f6>" . lookup-python-doc)))

(use-package saveplace
  :init
  (setq save-place-file "~/.emacs.d/saveplace")
  (setq-default save-place t))

(use-package server
  :config
  (when (not (server-running-p))
    (server-start)))

(use-package sh-script
  :config
  (setq
   magic-mode-alist (cons '("^##/bin/bash$" . shell-script-mode) magic-mode-alist)
   sh-shell-file "/bin/bash")
  (setq sh-basic-offset 8
	sh-indentation 8
	sh-test (append sh-test '((bash "[[  ]]" . 5))))

  (dir-locals-set-class-variables
   'shell-scripts-directory
   '((nil . ((mode . shell-script)))))
  (dir-locals-set-directory-class sjihs-xfstests-dir 'shell-scripts-directory)
  :hook
  ((sh-mode . (lambda ()
		(setq fill-column 80
		      whitespace-style
		      '(face trailing space-before-tab
			     space-after-tab indentation))
		(whitespace-mode))))
  :bind
  (("<f3>" . eshell)))

(use-package text-mode
  :hook
  ((text-mode . (lambda()
		  (set-fill-column 78)
		  (auto-fill-mode t)))))


(use-package tramp
  :config
  (setq tramp-default-method "ssh"))

(use-package winner
  :ensure t
  :config
  (winner-mode 1))

(use-package windmove
  :config
  (windmove-default-keybindings)
  ;; Move b/w buffers by holding shift and an arrow key.
  (windmove-default-keybindings 'shift))

(use-package window-numbering
  :ensure t
  :defer nil
  :config
  (window-numbering-mode 1)
  :hook
  ((minibuffer-setup . window-numbering-update)
   (minibuffer-exit . window-numbering-update)))

; Use control-arrow keys for window resizing
(global-set-key (kbd "C-<right>") 'enlarge-window-horizontally)
(global-set-key (kbd "C-<left>") 'shrink-window-horizontally)

(global-set-key (kbd "C-c f") 'set-frame-name)
(global-set-key (kbd "C-x f") 'select-frame-by-name)

;; Paren mode
(use-package paren
  :config
  (show-paren-mode t)
  (setq show-parent-style 'parenthesis))

;; Bpftrace mode
(use-package bpftrace-mode
  :ensure t)

(use-package kconfig-mode
  :ensure t
  :config
  (modify-syntax-entry ?_ "_" kconfig-mode-syntax-table))

;; Generic programming
(global-set-key (kbd "RET") 'newline-and-indent)
(global-set-key
 (kbd "<f1>")
 (lambda ()
   (interactive)
   (manual-entry (current-word))))
(set-face-attribute 'font-lock-string-face nil
		    :foreground "LightSalmon")
(set-face-attribute 'font-lock-comment-face nil
		    :foreground "color-136")
(set-face-attribute 'font-lock-variable-name-face nil
		    :foreground "yellow")
(set-face-attribute 'font-lock-function-name-face nil
		    :foreground "blue")
(set-face-attribute 'font-lock-type-face nil
		    :foreground "green")
(set-face-attribute 'font-lock-constant-face nil
		    :foreground "cyan")
(set-face-attribute 'font-lock-variable-name-face nil
		    :foreground "yellow")

;; Mode line configuration
(setq display-time-day-and-date t
      column-number-mode t
      display-time-mode t)
(set-face-attribute 'mode-line nil
		    :background "color-252"
		    :foreground "black")
(set-face-attribute 'mode-line-inactive nil
		    :inherit 'mode-line
		    :background "grey30"
		    :foreground "color-247")

;; Linux kernel build
(defun sjihs-kernel-make-oldconfig (src-dir build-dir config-file)
  (interactive "DSource directory:\nGBuild directory:\nfConfig file:")
  (let* ((old-dir default-directory)
	 (abs-path (expand-file-name build-dir)))
    (copy-file config-file "/tmp/.config" t)
    (when (file-exists-p abs-path)
      (delete-directory abs-path t))
    (make-directory abs-path)
    (copy-file "/tmp/.config" abs-path)
    (cd src-dir)
    (compile (format "make O=%s oldconfig" abs-path))
    (cd old-dir)))
(global-set-key (kbd "C-c k o") 'sjihs-kernel-make-oldconfig)

(defun sjihs-kernel-make (src-dir build-dir)
  (interactive "DSource directory:\nGBuild directory:")
  (let* ((old-dir default-directory)
	 (abs-path (expand-file-name build-dir)))
    (cd src-dir)
    (compile (format "make O=%s -j%d" abs-path sjihs-nr-cpus))
    (cd old-dir)))
(global-set-key (kbd "C-c k m") 'sjihs-kernel-make)

(defun sjihs-kernel-install-kernel-image (overwrite)
  (interactive "P")
  (let ((vmlinux-file
	 (concat sjihs-linux-build-dir "/" sjihs-linux-image-relative-path))
	(sjihs-cmd nil)
	vmlinux-targets)
    (if (file-exists-p vmlinux-file)
	(progn
	  (if sjihs-guest
	      (setq sjihs-cmd
		    (format
		     "scp -P 2222 %s root@localhost:%s"
		     vmlinux-file sjihs-vmlinux-install-location))

	    (when overwrite
	      (setq vmlinux-targets (directory-files "/boot/" t "vm.+" nil))
	      (setq sjihs-vmlinux-install-location
		    (completing-read "Possible targets:" vmlinux-targets)))
	    (setq sjihs-cmd
		  (format
		   "cp %s %s"
		   vmlinux-file sjihs-vmlinux-install-location)))
	  (compile sjihs-cmd))
      (message "%s does not not exist!" vmlinux-file))))
(global-set-key (kbd "C-c k b c") 'sjihs-kernel-install-kernel-image)

(defun sjihs-kernel-reboot ()
  (interactive)
  (let ((sjihs-cmd nil))
    (if sjihs-guest
	(setq sjihs-cmd "ssh -p 2222 root@localhost reboot")
      (setq sjihs-cmd "reboot"))
    (compile sjihs-cmd)))
(global-set-key (kbd "C-c k r") 'sjihs-kernel-reboot)

(defun sjihs-kernel-gen-gtags (src-dir)
  (interactive "DSource directory:")
  (let ((old-dir default-directory))
    (cd src-dir)
    (compile "make gtags")
    (cd old-dir)))
(global-set-key (kbd "C-c k g") 'sjihs-kernel-gen-gtags)

(defun sjihs-kernel-btrfs-next-make (clean-build-dir)
  (interactive "P")
  (let ((do-oldconfig nil)
	(old-dir default-directory)
	(compile-cmd "")
	(builder-list ())
	(builder))
    (when (and clean-build-dir (file-exists-p sjihs-linux-build-dir))
      (delete-directory sjihs-linux-build-dir t)
      (make-directory sjihs-linux-build-dir)
      (copy-file sjihs-linux-config-file
		 (concat sjihs-linux-build-dir "/.config"))
      (setq do-oldconfig t))
    (cd sjihs-linux-src-dir)
    (setq compile-cmd
	  (format (if do-oldconfig
		      "yes '' | make -j%d O=%s oldconfig;"
		    "") sjihs-nr-cpus sjihs-linux-build-dir))
    (setq compile-cmd
	  (concat compile-cmd
		  (format "yes '' | make -j%d O=%s %s"
			  sjihs-nr-cpus sjihs-linux-build-dir
			  sjihs-build-target)))
    (dolist (builder '(gcc-include gnu))
      (add-to-list
       'builder-list (assoc builder compilation-error-regexp-alist-alist)))

    (let ((compilation-error-regexp-alist-alist builder-list))
      (compile compile-cmd))
    (cd old-dir)))
(global-set-key (kbd "C-c k b k") 'sjihs-kernel-btrfs-next-make)

(defun sjihs-kernel-btrfs-gen-gtags (delete-tags-files)
  (interactive "P")
  (when delete-tags-files
    (dolist (gfile '("GPATH" "GRTAGS" "GTAGS"))
      (setq gfile
	    (format "%s/%s" sjihs-linux-src-dir gfile))
      (message "Deleting file: %s" gfile)
      (delete-file gfile)))
  (sjihs-kernel-gen-gtags sjihs-linux-src-dir))
(global-set-key (kbd "C-c k b g") 'sjihs-kernel-btrfs-gen-gtags)

(defun sjihs-kernel-select-prebuilt-xfsprogs ()
  (interactive)
  (let (prebuilt-entries target-entry symlink-name)
    (setq prebuilt-entries
	  (directory-files sjihs-xfsprogs-prebuilt-dir t
			   "xfsprogs-build.+" nil))
    (setq target-entry
	  (completing-read "Possible targets:" prebuilt-entries))
    (setq symlink-name
	  (format "%s/%s"
		  sjihs-xfsprogs-prebuilt-dir
		  sjihs-xfsprogs-prebuilt-symlink-prefix))
    (delete-file symlink-name)
    (make-symbolic-link target-entry symlink-name)))
(global-set-key (kbd "C-c k x s") 'sjihs-kernel-select-prebuilt-xfsprogs)

(defun sjihs-build-xfsprogs (clean-build)
  (interactive "P")
  (let ((cmd "xfsprogs-build.sh "))
    (if clean-build
	(setq cmd (concat cmd "1"))
      (setq cmd (concat cmd "0")))
    (compile cmd)))
(global-set-key (kbd "C-c k b x") 'sjihs-build-xfsprogs)

(defun sjihs-kernel-select-kernel-config ()
  (interactive)
  (let (config-list symlink-name)
    (setq symlink-name
	  (format "%s/%s"
		  sjihs-linux-configs-dir
		  sjihs-linux-config-symlink-suffix))
    (delete-file symlink-name)
    (setq config-list
	  (directory-files sjihs-linux-configs-dir t))
    (setq target-entry
	  (completing-read "Kernel configs:" config-list))
    (make-symbolic-link target-entry symlink-name)))
(global-set-key (kbd "C-c k b s") 'sjihs-kernel-select-kernel-config)

(defun sjihs-list-mounted-xfs ()
  (interactive)
  (compile (format "findmnt -rn -t xfs")))

;; GDB for kernel
(defun sjihs-gdb-execute-gdb-cmd (sub-cmd)
  (interactive "sGDB command: \n")
  (compile
   (format
    "gdb -batch %s/%s -ex '%s'"
    sjihs-linux-build-dir sjihs-vmlinux-relative-path sub-cmd)))
(global-set-key (kbd "C-c k d c") 'sjihs-gdb-execute-gdb-cmd)

(defun sjihs-gdb-map-function-offset (function-offset)
  (interactive "sFunction offset: \n")
  (let ((sub-cmd (format "list *(%s)"
			 function-offset)))
    (sjihs-gdb-execute-gdb-cmd sub-cmd)))
(global-set-key (kbd "C-c k d m") 'sjihs-gdb-map-function-offset)

(add-to-list 'compilation-error-regexp-alist-alist
	     '(gdb-list "0x.*(\\([a-zA-Z0-9_/.\\-]+\\):\\([0-9]+\\))." 1 2))
(add-to-list 'compilation-error-regexp-alist 'gdb-list)

(defun sjihs-gdb-disassemble-function ()
  (interactive)
  (let* ((func-name (thing-at-point 'symbol))
	 (sub-cmd (format "disassemble /m %s" func-name)))
    (sjihs-gdb-execute-gdb-cmd sub-cmd)))
(global-set-key (kbd "C-c k d d") 'sjihs-gdb-disassemble-function)

(defun sjihs-gdb-print-struct-mem-offset (struct-name sub-cmd)
  (interactive "sStructure: \nsMember: ")
  (let ((sub-cmd (format "print &(((struct %s *)0)->%s)"
			 struct-name sub-cmd)))
    (sjihs-gdb-execute-gdb-cmd sub-cmd)))
(global-set-key (kbd "C-c k d o") 'sjihs-gdb-print-struct-mem-offset)

(defun sjihs-gdb-print-size (identifier)
  (interactive "sIdentifier: \n")
  (let ((sub-cmd (format "print sizeof(%s)"
			 identifier)))
    (sjihs-gdb-execute-gdb-cmd sub-cmd)))
(global-set-key (kbd "C-c k d s") 'sjihs-gdb-print-size)

;; XFS
(require 'calc-ext)

(defun xfs-compute-max-btree-height (total-leaf-recs leaf-min-recs node-min-recs)
  (let (nr-blks
	expr
	(nr-levels 1))

    (setq total-leaf-recs (number-to-string total-leaf-recs))
    (setq leaf-min-recs (number-to-string leaf-min-recs))
    (setq node-min-recs (number-to-string node-min-recs))

    (setq expr (concat total-leaf-recs "+" leaf-min-recs "- 1"))
    (setq nr-blks (calc-eval expr))

    (setq expr (concat "idiv(" nr-blks "," leaf-min-recs ")"))
    (setq nr-blks (calc-eval expr))

    (message "nr-levels = %d; nr-leaf-blks = %s;" nr-levels nr-blks)

    (while (progn
	     (setq nr-levels (1+ nr-levels))

	     (setq expr (concat "idiv(" nr-blks "," node-min-recs ")"))
	     (setq nr-blks (calc-eval expr))

	     (message "nr-levels = %d; nr-blks = %s;"
		      nr-levels
		      (if (= (string-to-number nr-blks) 0)
			  "1"
			nr-blks))

	     (math-lessp 0 (string-to-number nr-blks))))

    (message "Height of tree = %s" nr-levels)

    nr-levels))

(defun xfs-compute-max-btree-blocks (total-leaf-recs leaf-min-recs node-min-recs)
  (let (nr-blks
	(total-nr-blks)
	expr
	(nr-levels 1))

    (setq total-leaf-recs (number-to-string total-leaf-recs))
    (setq leaf-min-recs (number-to-string leaf-min-recs))
    (setq node-min-recs (number-to-string node-min-recs))

    (setq expr (concat total-leaf-recs "+" leaf-min-recs "- 1"))
    (setq nr-blks (calc-eval expr))

    (setq expr (concat "idiv(" nr-blks "," leaf-min-recs ")"))
    (setq nr-blks (calc-eval expr))
    (setq total-nr-blks nr-blks)

    (message "nr-levels = %d; nr-leaf-blks = %s;" nr-levels nr-blks)

    (while (progn
	     (setq nr-levels (1+ nr-levels))

	     (setq expr (concat "idiv(" nr-blks "," node-min-recs ")"))
	     (setq nr-blks (calc-eval expr))
	     (setq total-nr-blks (calc-eval (concat total-nr-blks "+" nr-blks)))

	     (message "nr-levels = %d; nr-blks = %s; total-nr-blks = %s"
		      nr-levels
		      (if (= (string-to-number nr-blks) 0)
			  "1"
			nr-blks)
		      total-nr-blks)

	     (math-lessp 0 (string-to-number nr-blks))))

    (message "Height of tree = %s" nr-levels)
    (calc-sci-notation 1)
    (calc-eval (concat total-nr-blks "/" "1.0"))))

(defun xfs-compute-bmap-indirect-len (leaf-max-recs node-max-recs maxlevels
						    delalloc-len)
  (setq leaf-max-recs (number-to-string leaf-max-recs))
  (setq node-max-recs (number-to-string node-max-recs))
  (setq delalloc-len  (number-to-string delalloc-len))

  (let ((level 0)
	done
	(indirect-len 0)
	(maxrecs leaf-max-recs)
	expr)

    (while (and (< level maxlevels) (not done))
      (setq expr (concat delalloc-len "+" maxrecs "- 1"))
      (setq delalloc-len (calc-eval expr))

      (setq expr (concat "idiv(" delalloc-len "," maxrecs ")"))
      (setq delalloc-len (calc-eval expr))
      (setq indirect-len (+ indirect-len (string-to-number delalloc-len)))

      (when (= 1 (string-to-number delalloc-len))
	(setq indirect-len (+ indirect-len (- maxlevels (+ level 1))))
	(setq done t))

      (when (= level 0)
	(setq maxrecs node-max-recs))

      (setq level (1+ level)))

    indirect-len))

;; Perf
(require 'subr-x)
(require 'cl-lib)
(require 'tabulated-list)

(setq sjihs-kernel-conf-variables
      '(sjihs-linux-build-dir
	sjihs-vmlinux-relative-path
	sjihs-perf-log-file
	sjihs-perf-history))

(dolist (sjihs-var
	 sjihs-kernel-conf-variables)
  (when (not (boundp sjihs-var))
    (error "%s: %s variable not set" load-file-name (symbol-name sjihs-var))))

(defun sjihs-perf-func-line-map ()
  (interactive)
  (let ((func-name (thing-at-point 'symbol)))
    (compile
     (format
      "perf probe -L %s --vmlinux=%s/%s | tee"
      func-name sjihs-linux-build-dir sjihs-vmlinux-relative-path))))
(global-set-key (kbd "C-c k p l") 'sjihs-perf-func-line-map)

(defun sjihs-perf-func-var-map (line-nr)
  (interactive "P")
  (let ((func-name (thing-at-point 'symbol)))
    (compile
     (format
      "perf probe -q -V %s%s --vmlinux=%s/%s | tee"
      func-name
      (if line-nr
	  (format ":%s" line-nr)
	"")
      sjihs-linux-build-dir sjihs-vmlinux-relative-path))))
(global-set-key (kbd "C-c k p v") 'sjihs-perf-func-var-map)

(defvar sjihs-perf-probe-add-mode-map
  (let ((map (make-sparse-keymap)))
    (set-keymap-parent map special-mode-map)
    (define-key map (kbd "a") 'sjihs-perf-probe-add-var)
    (define-key map (kbd "c") 'sjihs-perf-probe-change-var-status)
    (define-key map (kbd "r") 'sjihs-perf-probe-rename-var)
    (define-key map (kbd "t") 'sjihs-perf-probe-set-var-type)
    (define-key map (kbd "C-c C-c") 'sjihs-perf-probe-add-exec)
    map)
  "Keymap for perf-probe-add mode.")

(defun sjihs-perf-probe-add-exec (&optional specify-event-name)
  (interactive "P")
  (goto-char (point-min))
  (let ((event-name "")
	entry perf-cmd-line var-name type-name)

    (when (equal specify-event-name '(4))
      (setq event-name
	    (read-string "Enter event name: "))
      (setq event-name (concat event-name "=")))

    (setq perf-cmd-line
	  (format "perf probe -a '%s%s:%d " event-name sjihs-func-name
		  sjihs-func-offset))

    (while (not (eobp))
      (setq entry (tabulated-list-get-entry))
      (forward-line)

      (when (string= (elt entry 0) "Y")
	(setq var-name (elt entry 3))
	(if (string= var-name "-")
	    (setq var-name (elt entry 1))
	  (setq var-name (concat var-name "=" (elt entry 1))))

	(setq type-name (elt entry 4))
	(if (string= type-name "-")
	    (setq type-name "")
	  (setq type-name (concat ":" type-name)))

	(setq perf-cmd-line
	      (concat perf-cmd-line var-name type-name " "))))

    (setq perf-cmd-line
	  (concat perf-cmd-line "' --vmlinux="
		  sjihs-linux-build-dir
		  sjihs-vmlinux-relative-path))

    (message "Perf command line: %s" perf-cmd-line)
    (kill-buffer)

    (with-temp-file sjihs-perf-history
      (insert-file-contents sjihs-perf-history)
      (insert perf-cmd-line)
      (insert "\n"))

    (compile perf-cmd-line)))

(defun sjihs-perf-probe-add-var ()
  (interactive)
  (let ((inhibit-read-only t) var var-name type entry-vector)
    (setq var
	  (read-string "Enter variable name: "))
    (setq var-name
	  (read-string "Rename variable: " nil nil "-"))
    (setq type
	  (completing-read "Enter type name: " sjihs-perf-data-types nil t))
    (setq entry-vector (vector "Y" var "-" var-name type))
    (add-to-list 'tabulated-list-entries (list nil entry-vector))
    (tabulated-list-print)))

(defun sjihs-perf-probe-change-var-status ()
  (interactive)
  (let (val entry (inhibit-read-only t))
    (setq entry (tabulated-list-get-entry))
    (if (string= (elt entry 0) "N")
	(setq val "Y")
      (setq val "N"))
    (tabulated-list-set-col 0 val t)))

(defun sjihs-perf-probe-rename-var ()
  (interactive)
  (let (var-name (inhibit-read-only t))
    (setq buffer-line (buffer-substring (point-at-bol) (point-at-eol)))
    (setq buffer-line (string-trim buffer-line))
    (setq buffer-line (split-string buffer-line "\t"))
    (setq var-name (read-string "Enter variable name: "))
    (tabulated-list-set-col 3 var-name t)))

(defconst sjihs-perf-data-types
  '("u8" "u16" "u32" "u64" "s8"
    "s16" "s32" "s64" "x8" "x16"
    "x32" "x64" "string"))

(defun sjihs-perf-probe-set-var-type ()
  (interactive)
  (let (type-name (inhibit-read-only t))
    (setq type-name
	  (completing-read "Enter type name: " sjihs-perf-data-types nil t))
    (tabulated-list-set-col 4 type-name t)))

(define-derived-mode sjihs-perf-probe-add-mode tabulated-list-mode "Perf probe add"
  "Major mode for constructing a \"perf probe -a\" command line.
\\{sjihs-perf-probe-add-mode-map}"
  (setq tabulated-list-format
	(vector '("Enabled" 7 nil :pad-left 0)
		'("Variable" 15 nil :pad-left 0)
		'("Type" 20 nil :pad-left 0)
		'("New name" 15 nil :pad-left 0)
		'("Perf type" 7 nil :pad-left 0)))
  (tabulated-list-init-header))

(defun sjihs--perf-extract-var-list (name offset)
  (let ((search-index 0)
	(intersect-list nil)
	var-list perf-probe-v var-type var type	len regexp)
    (setq perf-probe-v
	  (shell-command-to-string
	   (format "perf probe -V %s:%s --vmlinux=%s/%s"
		   name offset sjihs-linux-build-dir
		   sjihs-vmlinux-relative-path)))
    (setq perf-probe-v (string-trim perf-probe-v))

    ;; Perf lists "void *" as "(unknown_type"; Hence the regexp has a '(' to
    ;; match this case.
    (setq regexp "\\([ \t]+@.+\n\\)\\(\\([ \t]+[(a-zA-Z0-9_ \t\\*]+[\n]?\\)+\\)")

    (while (setq search-index (string-match regexp perf-probe-v search-index))
      (setq var-list (match-string 2 perf-probe-v))
      (setq var-list (string-trim var-list))
      (setq var-list (split-string var-list "\n"))
      (setq var-list
	    (mapcar
	     (lambda (e)
	       (setq var-type (split-string e))
	       (setq var (nth (1- (length var-type)) var-type))
	       (setq type "")
	       (dotimes (i (1- (length var-type)))
		 (setq type (concat type (nth i var-type) " ")))
	       (cons type var))
	     var-list))

      (if (= (length intersect-list) 0)
	  (setq intersect-list var-list)
	(setq intersect-list
	      (cl-intersection intersect-list var-list
			       :test (lambda (var1 var2)
				       (if (string= (cdr var1) (cdr var2))
					   t
					 nil)))))
      (setq search-index (1+ search-index)))

    intersect-list))

(defun sjihs-perf-probe-add (&optional probe-type)
  (interactive "P")

  (let ((func-name (thing-at-point 'symbol))
	perf-cmd-line func-offset
	entry-vector perf-edit-probe-vars
	event-name)

    ;; return probe
    (when (equal probe-type '(16))
      (setq perf-cmd-line
	    (format "perf probe -a '%s:%s' --vmlinux=%s/%s"
		    func-name "%return $retval"
		    sjihs-linux-build-dir
		    sjihs-vmlinux-relative-path)))

    (when (not (equal probe-type '(16)))
      (setq func-offset
	    (read-number "Enter function offset: " 0)))

    ;; Simple probe with optional function offset specified
    (when (equal probe-type '(4))
      (setq event-name
	    (read-string "Enter event name: "))
      (if (string= event-name "")
	  (setq event-name "")
	(setq event-name (concat event-name "=")))

      (setq perf-cmd-line
	    (format "perf probe -a '%s%s:%d' --vmlinux=%s/%s"
		    event-name func-name func-offset
		    sjihs-linux-build-dir
		    sjihs-vmlinux-relative-path)))

    (when (or (equal probe-type '(4)) (equal probe-type '(16)))
      (message "%s" perf-cmd-line)
      (compile perf-cmd-line))

    ;; Probe with variable values to be collected
    (when (not (or (equal probe-type '(4)) (equal probe-type '(16))))
      (if (get-buffer "perf-edit-probe-vars")
	  (kill-buffer "perf-edit-probe-vars"))
      (setq perf-edit-probe-vars (get-buffer-create "perf-edit-probe-vars"))
      (let ((func-var-list (sjihs--perf-extract-var-list func-name func-offset)))
	(switch-to-buffer perf-edit-probe-vars)
	(sjihs-perf-probe-add-mode)
	(erase-buffer)
	(setq tabulated-list-entries nil)
	(dolist (func-var func-var-list)
	  (setq entry-vector (vector "N" (cdr func-var) (car func-var) "-" "-"))
	  (add-to-list 'tabulated-list-entries (list nil entry-vector)))

	(tabulated-list-print)
	(setq-local sjihs-func-name func-name)
	(setq-local sjihs-func-offset func-offset)))))
(global-set-key (kbd "C-c k p a") 'sjihs-perf-probe-add)

(defun sjihs--perf-probe-list ()
  (let ((probe-points ()))
    (dolist (probe (split-string
		    (shell-command-to-string "perf probe -l")
		    "\n"))
      (setq probe (replace-regexp-in-string "^[ \t]+" "" probe))
      (setq probe (car (split-string probe " ")))
      (add-to-list 'probe-points probe))
    probe-points))

(defun sjihs-perf-probe-list ()
  (interactive)
  (let ((probe-points (sjihs--perf-probe-list))
	(probe-list ""))
    (dolist (probe probe-points)
      (setq probe-list (concat probe-list probe "\n")))
    (message "Probe points:\n")
    (message "%s" probe-list)))
(global-set-key (kbd "C-c k p L") 'sjihs-perf-probe-list)

(defun sjihs-perf-probe-delete (probe-name)
  (interactive
   (list  (completing-read "Probe to delete: " (sjihs--perf-probe-list))))
  (compile (format "perf probe -d %s" probe-name)))
(global-set-key (kbd "C-c k p d") 'sjihs-perf-probe-delete)

(defvar sjihs-perf-record-build-mode-map
  (let ((map (make-sparse-keymap)))
    (set-keymap-parent map special-mode-map)
    (define-key map (kbd "c") 'sjihs-perf-record-build-change-probe-status)
    map)
  "Keymap for perf-build-cmdline mode.")

(defun sjihs-perf-record-build-change-probe-status ()
  (interactive)
  (let (val entry (inhibit-read-only t))
    (setq entry (tabulated-list-get-entry))
    (if (string= (elt entry 0) "N")
	(setq val "Y")
      (setq val "N"))
    (tabulated-list-set-col 0 val t)))

(define-derived-mode sjihs-perf-record-build-mode tabulated-list-mode
  "Perf record"
  "Major mode for constructing a \"perf record ...\" command line."
  (setq tabulated-list-format
	(vector '("Enabled" 7 nil :pad-left 0)
		'("Probe" 20 nil :pad-right 0)))
  (tabulated-list-init-header))

(defun sjihs-perf-build-record-cmdline (&optional include-tracepoints)
  (interactive "P")
  (let ((probe-list nil)
	(events nil)
	(cmd-list nil))
    (setq cmd-list (list "perf probe -l"))
    (when include-tracepoints
      (add-to-list 'cmd-list "perf list tracepoint"))
    
    (dolist (cmd cmd-list)
      (setq events
	    (split-string
	     (string-trim (shell-command-to-string cmd))
	     "\n"))
      (setq probe-list
	    (append probe-list
		    (mapcar
		     (lambda (e)
		       (car (split-string
			     (replace-regexp-in-string "^[ \t]+" "" e)
			     " "))) events))))
    (if (get-buffer "perf-edit-record-probe")
	(kill-buffer "perf-edit-record-probe"))
    (setq perf-edit-record-probe (get-buffer-create "perf-edit-record-probe"))
    (switch-to-buffer perf-edit-record-probe)
    (sjihs-perf-record-build-mode)
    (erase-buffer)
    (setq tabulated-list-entries nil)
    (dolist (probe probe-list)
      (setq entry (vector "N" probe))
      (add-to-list 'tabulated-list-entries (list nil entry)))

    (tabulated-list-print)))
(global-set-key (kbd "C-c k p r") 'sjihs-perf-build-record-cmdline)

(defun sjihs-perf-script (print-trace)
  (interactive "P")
  (let (cmd-line perf-buffer)
    (if print-trace
	(setq cmd-line "perf script")
      (setq cmd-line "perf script -F comm,tid,cpu,time,event,trace"))
    (setq cmd-line (format "%s > %s" cmd-line sjihs-perf-log-file))
    (shell-command cmd-line)
    (setq perf-buffer (file-name-nondirectory sjihs-perf-log-file))
    (setq perf-buffer (get-buffer perf-buffer))
    (if perf-buffer
	(kill-buffer perf-buffer))
    (find-file-other-window sjihs-perf-log-file)))
(global-set-key (kbd "C-c k p s") 'sjihs-perf-script)

;; Process management
(defun sjihs-kill-proc (proc-name)
  (interactive
   (list
    (completing-read
     "Enter process name: "
     (funcall (lambda ()
		(let ((proc-list nil))
		  (dolist (proc-nr (list-system-processes))
		    (setq proc-list (cons (cdr (assoc 'comm (process-attributes proc-nr))) proc-list)))
		  proc-list))))))
  (let ((found 0))
    (dolist (proc-nr (list-system-processes))
      (let ((proc-attr (process-attributes proc-nr)))
	(when (eq (compare-strings proc-name nil nil
				   (cdr (assoc 'comm proc-attr))  nil (length proc-name)
				   t) t)
	  (setq found 1)
	  (signal-process proc-nr 9)
	  (message "Killing %s, pid: %d" proc-name proc-nr))))
    (if (= found 0)
	(message "%s: No such process" proc-name))))
(global-set-key (kbd "C-c s k") 'sjihs-kill-proc)


;; Computer science helpers
(defun sjihs-print-block-boundaries (page-start page-size block-size)
  (let ((page-end (1- (+ page-start page-size)))
	(block-start page-start)
	(output ""))

    (while (< block-start page-end)
      (setq output
	    (concat output
		    (format "%d - %d - "
			    block-start
			    (1- (+ block-start block-size)))))
      (setq block-start (+ block-start block-size)))
    output))

(defun sjihs-round-up-to-power-of-2 (src-num power-of-2)
  (interactive "nEnter number: \nnEnter power of 2: ")
  (let* ((nr-bits (truncate (log power-of-2 2)))
	 (mask (1- (lsh 1 nr-bits)))
	 (result (+ src-num mask)))
    (logand result (lognot mask))))

;; GPG stuff
(use-package pinentry
  :defer nil
  :ensure nil
  :config
  (setq epa-pinentry-mode 'loopback)
  (pinentry-start))

;; Mu4e and mail related stuff
(use-package mail-mode
  :hook ((mail-mode . turn-on-auto-fill)))

(when (require 'mu4e nil 'noerror)
  ;; use mu4e for e-mail in emacs
  (setq mail-user-agent 'mu4e-user-agent)

  (setq
   mu4e-view-auto-mark-as-read nil
   mu4e-change-filenames-when-moving t
   mu4e-update-interval (* 15 60)
   mu4e-index-update-in-background nil)

  (setq sendmail-program "/usr/bin/msmtp"
	send-mail-function 'smtpmail-send-it
	message-sendmail-f-is-evil t
	message-sendmail-extra-arguments '("--read-envelope-from")
	message-send-mail-function 'message-send-mail-with-sendmail)

  ;; don't keep message buffers around
  (setq message-kill-buffer-on-exit t)

  ;; Header view configuration
  (setq mu4e-headers-date-format "%d/%m/%Y %H:%M:%S")
  (setq mu4e-headers-fields
	'((:date . 19)
	  (:flags . 6)
	  (:from . 22)
	  (:subject)))

  (setq message-citation-line-format "On %a, %b %d, %Y at %r %z, %N wrote:")
  (setq message-citation-line-function 'message-insert-formatted-citation-line)
  (define-key mu4e-view-mode-map (kbd "#") 'gnus-article-hide-citation)

  (setq mu4e-context-policy 'pick-first)
  (setq mu4e-compose-context-policy 'always-ask)

  (setq mu4e-contexts
	`( ,(make-mu4e-context
	     :name "Work"
	     :enter-func (lambda () (mu4e-message "Entering work context"))
	     :leave-func (lambda () (mu4e-message "Leaving work context"))
	     :match-func (lambda (msg)
			   (when msg
			     (or (mu4e-message-contact-field-matches
				  msg
				  :to "chandan.babu@oracle.com")
				 (mu4e-message-contact-field-matches
				  msg
				  :cc "chandan.babu@oracle.com")
				 (mu4e-message-contact-field-matches
				  msg
				  :bcc "chandan.babu@oracle.com"))))
	     :vars `((user-mail-address . "chandan.babu@oracle.com")
		     (user-full-name .  "Chandan Babu R")
		     (mu4e-compose-signature . (concat "Chandan\n"))
		     ;; Do not include my email address in CC list when replying to a mail
		     (mu4e-user-mail-address-list . (quote ("chandan.babu@oracle.com")))
		     (mu4e-drafts-folder . "/work/Drafts")
		     (mu4e-sent-folder . "/work/Sent")
		     (mu4e-trash-folder . "/work/Trash")
		     (mu4e-maildir-shortcuts
		      .	(("/work/INBOX" . ?i)
			 ("/work/Sent" . ?s)
			 ("/work/Spam" . ?p)
			 ("/work/Trash" . ?t)
			 ("/work/misc" . ?m)
			 ("/work/linux-btrfs" . ?b)
			 ("/work/linux-bcachefs" . ?c)
			 ("/work/linux-xfs" . ?x)
			 ("/work/linux-block" . ?l)
			 ("/work/fstests" . ?f)
			 ("/work/linux-next" . ?n)
			 ("/work/linux-fsdevel" . ?d)
			 ("/work/linux-uek-group". ?u)))
		     (mu4e-get-mail-command . "/home/chandan/bin/sync-work-email.sh")
		     ;; Extra arguments to msmtp
		     (message-sendmail-extra-arguments . ("-a" "work"))
		     ;; don't save message to Sent Messages, Outlook takes care of this
		     (mu4e-sent-messages-behavior . delete)
		     ))
	   ,(make-mu4e-context
	     :name "Kerneldotorg"
	     :enter-func (lambda () (mu4e-message "Entering kernel context"))
	     :leave-func (lambda () (mu4e-message "Leaving kernel context"))
	     :match-func (lambda (msg)
			   (when msg
			     (or (mu4e-message-contact-field-matches
				  msg
				  :to "chandanbabu@kernel.org")
				 (mu4e-message-contact-field-matches
				  msg
				  :cc "chandanbabu@kernel.org")
				 (mu4e-message-contact-field-matches
				  msg
				  :bcc "chandanbabu@kernel.org"))))
	     :vars `((user-mail-address . "chandanbabu@kernel.org")
		     (user-full-name .  "Chandan Babu R")
		     (mu4e-compose-signature . (concat "Chandan\n"))
		     ;; Do not include my email address in CC list when replying to a mail
		     (mu4e-user-mail-address-list . (quote ("chandanbabu@kernel.org")))
		     (mu4e-drafts-folder . "/kerneldotorg/Drafts")
		     (mu4e-sent-folder . "/kerneldotorg/Sent")
		     (mu4e-trash-folder . "/kerneldotorg/Trash")
		     (mu4e-get-mail-command . "/home/chandan/bin/sync-kerneldotorg-email.sh")
		     (message-sendmail-extra-arguments . ("-a" "kerneldotorg"))
		     (mu4e-maildir-shortcuts
		      .	(("/kerneldotorg/INBOX" . ?i)))
		     (mu4e-sent-messages-behavior . sent)
		     )))
	   )

  (require 'mu4e-actions)

  (defun mu4e-save-mail-as-mbox (msg)
    (let ((path-name (mu4e-message-field msg :path))
	  (subject (mu4e-message-field msg :subject))
	  destdir destfile patch-file)
      (setq destdir
	    (read-directory-name "Enter destination directory: "
				 sjihs-patch-review-directory))
      (setq subject (s-replace "/" "_" subject))
      (setq subject (s-replace "[" "" subject))
      (setq subject (s-replace "]" "" subject))
      (setq subject (s-replace ":" "" subject))
      (setq subject (s-replace " " "_" subject))
      (setq subject (s-downcase subject))
      (setq destfile (concat destdir "/" subject ".mbox"))

      (copy-file path-name destfile)
      (message "Saved file as %s" destfile)))

  (add-to-list 'mu4e-view-actions
	       '("Save mail as mbox" . mu4e-save-mail-as-mbox) t)
  (add-to-list 'mu4e-view-actions
	       '("GitApply" . mu4e-action-git-apply-patch) t)
  (add-to-list 'mu4e-view-actions
	       '("MboxGitApply" . mu4e-action-git-apply-mbox) t)

  (setq gnus-visible-headers
	(concat gnus-visible-headers "\\|^List-Id:" "\\|^Message-Id:"))

  (set-face-attribute 'mu4e-compose-separator-face nil
		      :foreground "blue"
		      :slant 'normal
		      :inherit nil)

  (set-face-attribute 'mu4e-system-face nil
		      :foreground "brightred"
		      :slant 'normal
		      :inherit nil)

  (set-face-attribute 'mu4e-related-face nil
		      :foreground "color-245"
		      :slant 'normal
		      :inherit nil)
  (set-face-attribute 'mu4e-modeline-face nil
		      :foreground "black"
		      :slant 'normal
		      :weight 'bold
		      :inherit nil)

  (set-face-attribute 'gnus-header-from nil
		      :foreground "green")
  (set-face-attribute 'gnus-header-subject nil
		      :foreground "brightgreen")
  (set-face-attribute 'gnus-header-name nil
		      :foreground "brightcyan")
  (set-face-attribute 'gnus-signature nil
		      :foreground "yellow" :italic nil)
  (set-face-attribute 'gnus-header-content nil
		      :foreground "green" :italic nil)
  (set-face-attribute 'message-cited-text-2 nil
		      :foreground "green" :italic nil)

  (require 'gnus-cite)
  (set-face-attribute 'gnus-cite-2 nil
		      :foreground "brightcyan")
  (set-face-attribute 'gnus-cite-3 nil
		      :foreground "yellow")
  (set-face-attribute 'gnus-cite-attribution nil
		      :foreground "yellow")

  ;; Use sender's email id as keyid to obtain PGP signature key
  (setq mml-secure-openpgp-sign-with-sender t)

  ;; Verify signed messages
  (setq mm-verify-option 'known)

  (add-hook 'gnus-part-display-hook 'message-view-patch-highlight)

  ;; mu4e-headers-toggle-full-search or 'Q')
  )

;; Theme
(global-hl-line-mode)

;; Fun stuff
(defun sjihs-disapproval ()
  (interactive)
  (insert "ಠ_ಠ"))

;; Misc stuff
(set-face-attribute 'region nil
		    :background "color-32")

;; Bookmarks
(setq bookmark-default-file "~/.emacs.d/bookmarks"
      bookmark-save-flag 1)

(add-hook 'after-save-hook
	  'executable-make-buffer-file-executable-if-script-p)
(mouse-avoidance-mode 'animate)
(require 'scroll-bar)
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
      backup-directory-alist `(("." . ,sjihs-backup-directory))
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

;; Enable global highlight mode
(global-hi-lock-mode 1)

(global-set-key [remap dabbrev-expand] 'hippie-expand)
