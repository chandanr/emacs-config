(setq sjihs-ftrace-conf-variables
      '(sjihs-ftrace-sysfs-dir))

(dolist (sjihs-var
	 sjihs-ftrace-conf-variables)
  (when (not (boundp sjihs-var))
    (error "%s: %s variable not set" load-file-name (symbol-name sjihs-var))))

(defun sjihs-ftrace-function-graph-setup (kernel-symbol workload)
  (interactive "sFunction name: \nsCommand line: ")
  (let ((clear-ftrace-settings nil)
	(capture-proc nil)
	(setup-ftrace nil)
	(ftrace-buffer-name "*ftrace*"))

    (setq clear-ftrace-settings
	  (format
	   "echo 0 > %s/tracing_on && echo nop > %s/current_tracer \
&& echo > %s/set_graph_function"
	   sjihs-ftrace-sysfs-dir
	   sjihs-ftrace-sysfs-dir
	   sjihs-ftrace-sysfs-dir))
    
    (message "Executing command: %s" clear-ftrace-settings)
    (shell-command clear-ftrace-settings)

    (when (get-buffer ftrace-buffer-name)
      (kill-buffer ftrace-buffer-name))
    (setq ftrace-buffer-name
	  (get-buffer-create ftrace-buffer-name))

    (setq setup-ftrace
	  (format
	   "echo %s > %s/set_graph_function \
&& echo function_graph > %s/current_tracer;"
	   kernel-symbol sjihs-ftrace-sysfs-dir sjihs-ftrace-sysfs-dir))
    (message "Executing command: %s" setup-ftrace)
    (shell-command setup-ftrace)

    (setq capture-proc
	  (start-process-shell-command
	   "capture-ftrace"
	   ftrace-buffer-name
	   (format "cat %s/trace_pipe" sjihs-ftrace-sysfs-dir)))

    (setq setup-ftrace
	  (format
	   "echo 1 > %s/tracing_on && %s;"
	   sjihs-ftrace-sysfs-dir workload))

    (message "Executing command: %s" setup-ftrace)
    (shell-command setup-ftrace)

    ;; Give "capture-proc" some time to collect ftrace logs.
    (sleep-for 2)

    (delete-process capture-proc)
    (shell-command clear-ftrace-settings)
    (switch-to-buffer ftrace-buffer-name)))

(global-set-key (kbd "C-c k f g x") 'sjihs-ftrace-function-graph-setup)

(defun sjihs-set-function-graph-notrace (kernel-symbol &optional no-append)
  (interactive "sFunction name: \nP")

  (let ((cmd-line ""))
    (setq cmd-line
	  (format "echo %s %s /sys/kernel/debug/tracing/set_graph_notrace"
		  kernel-symbol
		  (if no-append
		      ">"
		    ">>")))
    (compile cmd-line)))

(global-set-key (kbd "C-c k f g n") 'sjihs-set-function-graph-notrace)
