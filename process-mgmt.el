(defun sjihs-kill-proc (proc-name)
  (interactive
   (list
    (completing-read
     "Enter process name: "
     (funcall (lambda ()
                (let ((proc-list nil))
                  (dolist (proc-nr (list-system-processes))
                    (setq proc-list (cons (cdr (assoc 'comm (process-attributes proc-nr))) proc-list)))
                  proc-list))))))
  (let ((found 0))
    (dolist (proc-nr (list-system-processes))
      (let ((proc-attr (process-attributes proc-nr)))
        (when (eq (compare-strings proc-name nil nil
                                   (cdr (assoc 'comm proc-attr))  nil (length proc-name)
                                   t) t)
          (setq found 1)
          (signal-process proc-nr 9)
          (message "Killing %s, pid: %d" proc-name proc-nr))))
    (if (= found 0)
        (message "%s: No such process" proc-name))))
(global-set-key (kbd "C-c s k") 'sjihs-kill-proc)
