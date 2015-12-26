(defun sjihs-kernel-make-oldconfig (src-dir build-dir config-file)
  (interactive "DSource directory:\nGBuild directory:\nfConfig file:")
  (let* ((old-dir default-directory)
	 (abs-path (expand-file-name build-dir)))
    (copy-file config-file "/tmp/.config" t)
    (when (file-exists-p abs-path)
      (delete-directory abs-path t)
      (make-directory abs-path)
      (copy-file "/tmp/.config" abs-path))
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

;; Unfortunately 'compile' is an async function.
;; (defun sjihs-kernel-config-and-build (src-dir build-dir config-file)
;;   (interactive "DSource directory:\nGBuild directory:\nfConfig file:")
;;   (sjihs-kernel-make-oldconfig src-dir build-dir config-file)
;;   (sjihs-kernel-make src-dir build-dir))

(defun sjihs-kernel-copy-bzimage-to-guest (build-dir)
  (interactive "DBuild directory:")
  (let ((vmlinux-file (concat build-dir "/" "arch/x86_64/boot/bzImage")))
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


(setq sjihs-btrfs-next-build-dir (expand-file-name "~/junk/build/btrfs-next/")
      sjihs-btrfs-next-config-file (expand-file-name "~/Dropbox/documents/linux-kernel/btrfs/kernel-configs/btrfs-next-config-4.1-rc6")
      ;; sjihs-btrfs-next-config-file (expand-file-name "~/Dropbox/documents/linux-kernel/btrfs/kernel-configs/btrfs-next-config-4.0-rc5")
      ;; sjihs-btrfs-next-config-file (expand-file-name "~/google-drive/documents/linux-kernel/btrfs/kernel-configs/integration-config")
      ;; sjihs-btrfs-next-config-file (expand-file-name "~/google-drive/documents/linux-kernel/btrfs/kernel-configs/btrfs-next-config.3.19-rc5")
      ;; sjihs-btrfs-next-config-file (expand-file-name "~/google-drive/documents/linux-kernel/btrfs/kernel-configs/btrfs-next-config-3.18-rc6")
      ;; sjihs-btrfs-next-config-file (expand-file-name "~/google-drive/documents/linux-kernel/btrfs/kernel-configs/btrfs-next-config-2.19-rc5")
      ;; sjihs-btrfs-next-config-file (expand-file-name "~/google-drive/documents/linux-kernel/btrfs/kernel-configs/btrfs-next-config-3.17-rc5")
      ;; sjihs-btrfs-next-config-file (expand-file-name "~/google-drive/documents/linux-kernel/btrfs/kernel-configs/btrfs-next-config-3.16")
      ;; sjihs-btrfs-next-config-file (expand-file-name "~/google-drive/documents/linux-kernel/btrfs/kernel-configs/btrfs-next-config-3.15")
      ;; sjihs-btrfs-next-config-file (expand-file-name "~/google-drive/documents/linux-kernel/btrfs/kernel-configs/btrfs-next-config-3.14")
      ;; sjihs-btrfs-next-config-file (expand-file-name "~/google-drive/documents/linux-kernel/btrfs/kernel-configs/btrfs-next-config-3.14-rc4")
      ;; sjihs-btrfs-next-config-file (expand-file-name "~/google-drive/documents/linux-kernel/btrfs/kernel-configs/btrfs-next-config-3.14-rc4-2")
      ;;sjihs-btrfs-next-config-file (expand-file-name "~/google-drive/documents/linux-kernel/btrfs/kernel-configs/btrfs-next-config")
      sjihs-btrfs-next-src-dir (expand-file-name "~/code/repos/linux/btrfs-next/"))
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

(setq sjihs-btrfs-progs-unstable-dir
      (expand-file-name "~/code/repos/"))
(defun sjihs-kernel-btrfs-progs-copy-and-make ()
  (interactive)
  (let* ((old-dir default-directory))
    (cd sjihs-btrfs-progs-unstable-dir)
    (compile (format "%s; %s; %s; %s; %s; %s"
		     "ssh -p 2222 root@localhost -C \"rm -rf /root/btrfs-progs.tar.bz2\""
		     "ssh -p 2222 root@localhost -C \"rm -rf /root/btrfs-progs\""
		     "tar cjf btrfs-progs.tar.bz2 btrfs-progs --exclude-vcs"
		     "scp -P 2222 btrfs-progs.tar.bz2 root@localhost:/root"
		     "ssh -p 2222 root@localhost -C \"tar xvf btrfs-progs.tar.bz2\""
		     "ssh -p 2222 root@localhost -C \"cd btrfs-progs; make clean; make\""))
    (cd old-dir)))
  
(defun sjihs-kernel-btrfs-progs-make (clean-build-dir)
  (interactive "P")
  (let ((old-dir default-directory)
	(compile-cmd ""))
    (when (not (null clean-build-dir))
      (setq compile-cmd "make clean; "))
    (cd (concat sjihs-btrfs-progs-unstable-dir "/devel"))
    (compile (format "%smake -j4" compile-cmd))
    (cd old-dir)))
(global-set-key (kbd "C-c k b p m") 'sjihs-kernel-btrfs-progs-make)
