(setq sjihs-kernel-conf-variables
      '(sjihs-btrfs-next-build-dir
	sjihs-vmlinux-relative-path))

(dolist (sjihs-var
	 sjihs-kernel-conf-variables)
  (when (not (boundp sjihs-var))
    (error "%s: %s variable not set" load-file-name (symbol-name sjihs-var))))

(defun sjihs-perf-func-line-map (function-name)
  (interactive "sFunction name: \n")
  (compile
   (format
    "perf probe -L %s --vmlinux=%s/%s | tee"
    function-name sjihs-btrfs-next-build-dir sjihs-vmlinux-relative-path)))

(defun sjihs-perf-func-var-map (function-name)
  (interactive "sFunction name: \n")
  (compile
   (format
    "perf probe -V %s --vmlinux=%s/%s | tee"
    function-name sjihs-btrfs-next-build-dir sjihs-vmlinux-relative-path)))

(defun sjihs-perf-probe-add ()
  (interactive)
  (let ((func-name (thing-at-point 'symbol))
	(perf-cmd-line))
    (setq perf-cmd-line
	  (format "perf probe -a %s --vmlinux=%s/%s"
		  func-name sjihs-btrfs-next-build-dir
		  sjihs-vmlinux-relative-path))
    (message "%s" perf-cmd-line)
    (shell-command perf-cmd-line)))
(global-set-key (kbd "C-c k p a") 'sjihs-perf-probe-add)

(defun sjihs-perf-probe-delete (probe-name)
  (interactive
   (list
    (completing-read
     "Probe to delete: "
     (funcall (lambda ()
		(let ((probe-points ()))
		  (dolist (probe (split-string
				  (shell-command-to-string "perf probe -l")
				  "\n"))
		    (setq probe (replace-regexp-in-string "^[ \t]+" "" probe))
		    (setq probe (car (split-string probe " ")))
		    (add-to-list 'probe-points probe))
		  probe-points))))))
  (shell-command (format "perf probe -d %s" probe-name)))
(global-set-key (kbd "C-c k p d") 'sjihs-perf-probe-delete)
