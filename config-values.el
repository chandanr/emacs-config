(setq
 ;; kernel build configuration values                                                                                                                                                                                         
 sjihs-btrfs-next-src-dir (expand-file-name "~/code/repos/linux/btrfs-next/")
 sjihs-btrfs-next-build-dir (expand-file-name "~/junk/build/btrfs-next/")
 sjihs-vmlinux-relative-path "arch/x86_64/boot/bzImage"
 sjihs-btrfs-next-config-file (expand-file-name "~/google-drive/documents/linux-kernel/btrfs/kernel-configs/btrfs-next-config-4.2.0-rc5")
 sjihs-vmlinux-install-location "/boot/vmlinux-4.0.0-rc5-11671-gcbab598"
 sjihs-build-target "bzImage"

 ;; Gtags                                                                                                                                                                                                                     
 ;; ftrace sysfs entry
 sjihs-ftrace-sysfs-dir "/sys/kernel/debug/tracing/"
 sjihs-gtags-path "/usr/share/emacs/site-lisp/gtags.elc"

 ;; Org mode                                                                                                                                                                                                                  
 sjihs-gtd-org-directory "~/google-drive/documents/gtd"
 sjihs-gtd-org-agenda-files '("~/google-drive/documents/gtd/gtd.txt")

 ;; Guest/Host                                                                                                                                                                                                                
 sjihs-guest t

 ;; Misc
 sjihs-browser-program "google-chrome"
 load-prefer-newer t)
