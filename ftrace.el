(setq sjihs-ftrace-conf-variables
      '(sjihs-ftrace-sysfs-dir))

(dolist (sjihs-var
	 sjihs-ftrace-conf-variables)
  (when (not (boundp sjihs-var))
    (error "%s: %s variable not set" load-file-name (symbol-name sjihs-var))))

(defun sjihs-ftrace-function-graph-setup (kernel-symbol workload)
  (interactive "sFunction name: \nsCommand line: ")
  (let ((clear-ftrace-settings nil)
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

    (setq setup-ftrace
	  (format
	   "echo %s > %s/set_graph_function \
&& echo function_graph > %s/current_tracer \
&& echo 1 > %s/tracing_on && %s;"
	   kernel-symbol sjihs-ftrace-sysfs-dir
	   sjihs-ftrace-sysfs-dir sjihs-ftrace-sysfs-dir
	   workload))

    (message "Executing command: %s" setup-ftrace)
    (shell-command setup-ftrace)

    ;; For unknown reasons Emacs reads only the partial
    ;; contents of the trace file. Hence the below kludge.
    (shell-command
     (format "cat %s/trace" sjihs-ftrace-sysfs-dir)
     (get-buffer-create ftrace-buffer-name))

    (shell-command clear-ftrace-settings)
    (switch-to-buffer ftrace-buffer-name)))

(global-set-key (kbd "C-c k f g") 'sjihs-ftrace-function-graph-setup)
