(setq sjihs-kernel-conf-variables
      '(sjihs-btrfs-next-build-dir
        sjihs-vmlinux-relative-path))

(dolist (sjihs-var
         sjihs-kernel-conf-variables)
  (when (not (boundp sjihs-var))
    (error "%s: %s variable not set" load-file-name (symbol-name sjihs-var))))

(defun sjihs-execute-gdb-cmd (sub-cmd)
  (compile
   (format
    "gdb -batch %s/%s -ex '%s'"
    sjihs-btrfs-next-build-dir sjihs-vmlinux-relative-path sub-cmd)))

(defun sjihs-gdb-map-function-offset (function-offset)
  (interactive "sFunction offset: \n")
  (let ((sub-cmd (format "list *(%s)"
			 function-offset)))
    (sjihs-execute-gdb-cmd sub-cmd)))
(global-set-key (kbd "C-c k d m") 'sjihs-gdb-map-function-offset)

(defun sjihs-gdb-disassemble-function ()
  (interactive)
  (let* ((func-name (thing-at-point 'symbol))
	 (sub-cmd (format "disassemble /m %s" func-name)))
    (sjihs-execute-gdb-cmd sub-cmd)))
(global-set-key (kbd "C-c k d d") 'sjihs-gdb-disassemble-function)
