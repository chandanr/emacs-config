(setq sjihs-kernel-conf-variables
      '(sjihs-btrfs-next-build-dir
        sjihs-vmlinux-relative-path))

(dolist (sjihs-var
         sjihs-kernel-conf-variables)
  (when (not (boundp sjihs-var))
    (error "%s: %s variable not set" load-file-name (symbol-name sjihs-var))))

(defun sjihs-gdb-map-function-offset (function-offset)
  (interactive "sFunction offset: \n")
  (compile
   (format
    "gdb -batch %s/%s -ex 'list *(%s)'"
    sjihs-btrfs-next-build-dir sjihs-vmlinux-relative-path function-offset)))
