(setq sjihs-kernel-conf-variables
      '(sjihs-btrfs-next-build-dir
	sjihs-vmlinux-relative-path))

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
      func-name sjihs-btrfs-next-build-dir sjihs-vmlinux-relative-path))))
(global-set-key (kbd "C-c k p l") 'sjihs-perf-func-line-map)

(defun sjihs-perf-func-var-map ()
  (interactive)
  (let ((func-name (thing-at-point 'symbol)))
    (compile
     (format
      "perf probe -V %s --vmlinux=%s/%s | tee"
    func-name sjihs-btrfs-next-build-dir sjihs-vmlinux-relative-path))))
(global-set-key (kbd "C-c k p v") 'sjihs-perf-func-var-map)

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

(defun sjihs-perf-build-record-cmdline ()
  (interactive)
  (let ((record-events)
	(events)
	(cmd-line)
	(more-events t))
    (setq events
	  (split-string
	   (shell-command-to-string "perf list tracepoint")
	   "\n"))
    (setq events
	  (mapcar
	   (lambda (e)
	     (split-string
	      (replace-regexp-in-string "^[ \t]+" "" e)
	      " ")) events))
    (while more-events
      (add-to-list 'record-events
		   (completing-read "Event name: " events))
      (setq more-events (y-or-n-p "Add more events? ")))
    (setq cmd-line "perf record ")
    (dolist (tp record-events)
      (setq cmd-line (concat cmd-line " -e " tp)))
    (message "%s" cmd-line)))
(global-set-key (kbd "C-c k p r") 'sjihs-perf-build-record-cmdline)
