;; TODO: Detect if the kernel is to be copied to a guest or onto
;; the current machine.

(setq sjihs-kernel-conf-variables
      '(sjihs-btrfs-next-src-dir
	sjihs-btrfs-next-build-dir
	sjihs-btrfs-next-config-file
	sjihs-vmlinux-relative-path))

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

(defun sjihs-kernel-copy-bzimage-to-guest (build-dir)
  (interactive "DBuild directory:")
  (let ((vmlinux-file (concat build-dir "/" sjihs-vmlinux-relative-path)))
    (if (file-exists-p vmlinux-file)
	(progn
	  (compile
	   (format
	    "scp -P 2222 %s root@localhost:/boot/vmlinuz-linux-mod"
	    vmlinux-file)))
      (message "%s does not not exist!" vmlinux-file))))

(defun sjihs-kernel-reboot-guest ()
  (interactive)
  (compile "ssh -p 2222 root@localhost reboot"))
(global-set-key (kbd "C-c k r") 'sjihs-kernel-reboot-guest)

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
		    "")  sjihs-btrfs-next-build-dir))
    (setq compile-cmd
	  (concat compile-cmd
	    (format "; make -j3 O=%s bzImage" sjihs-btrfs-next-build-dir)))
    (compile compile-cmd)
    (cd old-dir)))
(global-set-key (kbd "C-c k b m") 'sjihs-kernel-btrfs-next-make)

(defun sjihs-kernel-btrfs-gen-gtags ()
  (interactive)
  (sjihs-kernel-gen-gtags sjihs-btrfs-next-src-dir))
(global-set-key (kbd "C-c k b g") 'sjihs-kernel-btrfs-gen-gtags)

(defun sjihs-kernel-btrfs-copy-bzimage-to-guest ()
  (interactive)
  (sjihs-kernel-copy-bzimage-to-guest (expand-file-name "~/junk/build/btrfs-next")))
(global-set-key (kbd "C-c k b c") 'sjihs-kernel-btrfs-copy-bzimage-to-guest)
