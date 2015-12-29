(setq sjihs-kernel-conf-variables
      '(sjihs-btrfs-next-src-dir
	sjihs-btrfs-next-build-dir
	sjihs-btrfs-next-config-file
	sjihs-vmlinux-relative-path
	sjihs-guest
	sjihs-vmlinux-install-location
	sjihs-build-target))

(dolist (sjihs-var
	 sjihs-kernel-conf-variables)
  (when (not (boundp sjihs-var))
    (error "%s: %s variable not set" load-file-name (symbol-name sjihs-var))))

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
    (compile (format "make O=%s -j3" abs-path))
    (cd old-dir)))
(global-set-key (kbd "C-c k m") 'sjihs-kernel-make)

(defun sjihs-kernel-install-bzimage ()
  (interactive)
  (let ((vmlinux-file
	 (concat sjihs-btrfs-next-build-dir "/" sjihs-vmlinux-relative-path))
	(sjihs-cmd nil))
    (if (file-exists-p vmlinux-file)
	(progn
	  (if sjihs-guest
	      (setq sjihs-cmd
		    (format
		     "scp -P 2222 %s root@localhost:%s"
		     vmlinux-file sjihs-vmlinux-install-location))
	    (setq sjihs-cmd
		  (format
		   "cp %s %s"
		   vmlinux-file sjihs-vmlinux-install-location)))
	  (compile sjihs-cmd))
      (message "%s does not not exist!" vmlinux-file))))
(global-set-key (kbd "C-c k b c") 'sjihs-kernel-install-bzimage)

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
	(compile-cmd ""))
    (when (and clean-build-dir (file-exists-p sjihs-btrfs-next-build-dir))
      (delete-directory sjihs-btrfs-next-build-dir t)
      (make-directory sjihs-btrfs-next-build-dir)
      (copy-file sjihs-btrfs-next-config-file
		 (concat sjihs-btrfs-next-build-dir "/.config"))
      (setq do-oldconfig t))
    (cd sjihs-btrfs-next-src-dir)
    (setq compile-cmd
	  (format (if do-oldconfig
		      "make -j3 O=%s oldconfig"
		    "") sjihs-btrfs-next-build-dir))
    (setq compile-cmd
	  (concat compile-cmd
		  (format "; make -j3 O=%s %s"
			  sjihs-btrfs-next-build-dir sjihs-build-target)))
    (compile compile-cmd)
    (cd old-dir)))
(global-set-key (kbd "C-c k b m") 'sjihs-kernel-btrfs-next-make)

(defun sjihs-kernel-btrfs-gen-gtags ()
  (interactive)
  (sjihs-kernel-gen-gtags sjihs-btrfs-next-src-dir))
(global-set-key (kbd "C-c k b g") 'sjihs-kernel-btrfs-gen-gtags)

