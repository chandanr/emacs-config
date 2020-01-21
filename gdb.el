(setq sjihs-kernel-conf-variables
      '(sjihs-btrfs-next-build-dir
        sjihs-vmlinux-relative-path))

(dolist (sjihs-var
         sjihs-kernel-conf-variables)
  (when (not (boundp sjihs-var))
    (error "%s: %s variable not set" load-file-name (symbol-name sjihs-var))))

(defun sjihs-gdb-execute-gdb-cmd (sub-cmd)
  (interactive "sGDB command: \n")
  (compile
   (format
    "gdb -batch %s/%s -ex '%s'"
    sjihs-btrfs-next-build-dir sjihs-vmlinux-relative-path sub-cmd)))
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
