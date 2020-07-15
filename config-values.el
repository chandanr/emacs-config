(setq
 ;; kernel build configuration values
 sjihs-btrfs-next-src-dir (expand-file-name "~/repos/linux/")
 sjihs-btrfs-next-build-dir (expand-file-name "/root/disk-imgs/junk/build/btrfs-next/")
 sjihs-kernel-image-relative-path "vmlinux"
 sjihs-vmlinux-relative-path "vmlinux"
 sjihs-kernel-configs-dir (expand-file-name "/root/kernel-configs/")
 sjihs-kernel-config-symlink-suffix "kernel-config"
 sjihs-btrfs-next-config-file
 (expand-file-name (format "%s/%s"
			   "/root/kernel-configs/"
			   sjihs-kernel-config-symlink-suffix))

 sjihs-vmlinux-install-location "/boot/vmlinuz-mod"
 sjihs-build-target "zImage"

 ;; ftrace sysfs entry
 sjihs-ftrace-sysfs-dir "/sys/kernel/debug/tracing/"

 ;; Perf configuration values
 sjihs-perf-log-file (expand-file-name "/root/junk/perf.log")
 sjihs-perf-history (expand-file-name "~/.perf-history")

 ;; Gtags
 sjihs-gtags-path "/usr/share/emacs/site-lisp/gtags.elc"

 ;; Org mode                                                                                                                                                                                                                  
 sjihs-gtd-org-directory "~/google-drive/documents/gtd"
 sjihs-gtd-org-agenda-files '("~/google-drive/documents/gtd/gtd.txt")

 ;; Guest/Host                                                                                                                                                                                                                
 sjihs-guest t

 ;; xfs
 sjihs-xfsprogs-prebuilt-dir "/opt/"
 sjihs-xfsprogs-prebuilt-symlink-prefix "xfsprogs-build"
 ;; Misc
 sjihs-browser-program "google-chrome"
 sjihs-nr-cpus 10
 load-prefer-newer t)
