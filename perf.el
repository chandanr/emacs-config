;; This has definition of string-trim
(require 'subr-x)
(require 'cl-lib)
(require 'tabulated-list)

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

(defun sjihs-perf-func-var-map (line-nr)
  (interactive "P")
  (let ((func-name (thing-at-point 'symbol)))
    (compile
     (format
      "perf probe -q -V %s%s --vmlinux=%s/%s | tee"
      func-name
      (if line-nr
	  (format ":%s" line-nr)
	"")
      sjihs-btrfs-next-build-dir sjihs-vmlinux-relative-path))))
(global-set-key (kbd "C-c k p v") 'sjihs-perf-func-var-map)

(defvar sjihs-perf-probe-add-mode-map
  (let ((map (make-sparse-keymap)))
    (set-keymap-parent map special-mode-map)
    (define-key map (kbd "a") 'sjihs-perf-probe-add-var)
    (define-key map (kbd "c") 'sjihs-perf-probe-change-var-status)
    (define-key map (kbd "r") 'sjihs-perf-probe-rename-var)
    (define-key map (kbd "t") 'sjihs-perf-probe-set-var-type)
    (define-key map (kbd "C-c C-c") 'sjihs-perf-probe-add-exec)
    map)
  "Keymap for perf-probe-add mode.")

(defun sjihs-perf-probe-add-exec (&optional specify-event-name)
  (interactive "P")
  (goto-char (point-min))
  (let ((event-name "")
	entry perf-cmd-line var-name type-name)

    (when (equal specify-event-name '(4))
      (setq event-name
	    (read-string "Enter event name: "))
      (setq event-name (concat event-name "=")))

    (setq perf-cmd-line
	  (format "perf probe -a '%s%s:%d " event-name sjihs-func-name
		  sjihs-func-offset))

    (while (not (eobp))
      (setq entry (tabulated-list-get-entry))
      (forward-line)

      (when (string= (elt entry 0) "Y")
	(setq var-name (elt entry 3))
	(if (string= var-name "-")
	    (setq var-name (elt entry 1))
	  (setq var-name (concat var-name "=" (elt entry 1))))

	(setq type-name (elt entry 4))
	(if (string= type-name "-")
	    (setq type-name "")
	  (setq type-name (concat ":" type-name)))

	(setq perf-cmd-line
	      (concat perf-cmd-line var-name type-name " "))))

    (setq perf-cmd-line
	  (concat perf-cmd-line "' --vmlinux="
		  sjihs-btrfs-next-build-dir
		  sjihs-vmlinux-relative-path))

    (message "Perf command line: %s" perf-cmd-line)
    (kill-buffer)
    (compile perf-cmd-line)))

(defun sjihs-perf-probe-add-var ()
  (interactive)
  (let ((inhibit-read-only t) var var-name type entry-vector)
    (setq var
	  (read-string "Enter variable name: "))
    (setq var-name
	  (read-string "Rename variable: " nil nil "-"))
    (setq type
	  (completing-read "Enter type name: " sjihs-perf-data-types nil t))
    (setq entry-vector (vector "Y" var "-" var-name type))
    (add-to-list 'tabulated-list-entries (list nil entry-vector))
    (tabulated-list-print)))

(defun sjihs-perf-probe-change-var-status ()
  (interactive)
  (let (val entry (inhibit-read-only t))
    (setq entry (tabulated-list-get-entry))
    (if (string= (elt entry 0) "N")
	(setq val "Y")
      (setq val "N"))
    (tabulated-list-set-col 0 val t)))

(defun sjihs-perf-probe-rename-var ()
  (interactive)
  (let (var-name (inhibit-read-only t))
    (setq buffer-line (buffer-substring (point-at-bol) (point-at-eol)))
    (setq buffer-line (string-trim buffer-line))
    (setq buffer-line (split-string buffer-line "\t"))
    (setq var-name (read-string "Enter variable name: "))
    (tabulated-list-set-col 3 var-name t)))

(defconst sjihs-perf-data-types
  '("u8" "u16" "u32" "u64" "s8"
    "s16" "s32" "s64" "x8" "x16"
    "x32" "x64" "string"))

(defun sjihs-perf-probe-set-var-type ()
  (interactive)
  (let (type-name (inhibit-read-only t))
    (setq type-name
	  (completing-read "Enter type name: " sjihs-perf-data-types nil t))
    (tabulated-list-set-col 4 type-name t)))

(define-derived-mode sjihs-perf-probe-add-mode tabulated-list-mode "Perf probe add"
  "Major mode for constructing a \"perf probe -a\" command line.
\\{sjihs-perf-probe-add-mode-map}"
  (setq tabulated-list-format
	(vector '("Enabled" 7 nil :pad-left 0)
		'("Variable" 15 nil :pad-left 0)
		'("Type" 20 nil :pad-left 0)
		'("New name" 15 nil :pad-left 0)
		'("Perf type" 7 nil :pad-left 0)))
  (tabulated-list-init-header))

(defun sjihs--perf-extract-var-list (name offset)
  (let ((search-index 0)
	(intersect-list nil)
	var-list perf-probe-v var-type var type	len regexp)
    (setq perf-probe-v
	  (shell-command-to-string
	   (format "perf probe -V %s:%s --vmlinux=%s/%s"
		   name offset sjihs-btrfs-next-build-dir
		   sjihs-vmlinux-relative-path)))
    (setq perf-probe-v (string-trim perf-probe-v))

    ;; Perf lists "void *" as "(unknown_type"; Hence the regexp has a '(' to
    ;; match this case.
    (setq regexp "\\([ \t]+@.+\n\\)\\(\\([ \t]+[(a-zA-Z0-9_ \t\\*]+[\n]?\\)+\\)")

    (while (setq search-index (string-match regexp perf-probe-v search-index))
	(setq var-list (match-string 2 perf-probe-v))
	(setq var-list (string-trim var-list))
	(setq var-list (split-string var-list "\n"))
	(setq var-list
	      (mapcar
	       (lambda (e)
		 (setq var-type (split-string e))
		 (setq var (nth (1- (length var-type)) var-type))
		 (setq type "")
		 (dotimes (i (1- (length var-type)))
		   (setq type (concat type (nth i var-type) " ")))
		 (cons type var))
	       var-list))

	(if (= (length intersect-list) 0)
	    (setq intersect-list var-list)
	  (setq intersect-list
	      (cl-intersection intersect-list var-list
			       :test (lambda (var1 var2)
				       (if (string= (cdr var1) (cdr var2))
					   t
					 nil)))))
      (setq search-index (1+ search-index)))

    intersect-list))

(defun sjihs-perf-probe-add (&optional probe-type)
  (interactive "P")

  (let ((func-name (thing-at-point 'symbol))
	perf-cmd-line func-offset
	entry-vector perf-edit-probe-vars
	event-name)

    ;; return probe
    (when (equal probe-type '(16))
      (setq perf-cmd-line
	    (format "perf probe -a '%s:%s' --vmlinux=%s/%s"
		    func-name "%return $retval"
		    sjihs-btrfs-next-build-dir
		    sjihs-vmlinux-relative-path)))

    (when (not (equal probe-type '(16)))
      (setq func-offset
	    (read-number "Enter function offset: " 0)))

    ;; Simple probe with optional function offset specified
    (when (equal probe-type '(4))
      (setq event-name
	    (read-string "Enter event name: "))
      (if (string= event-name "")
	  (setq event-name "")
	(setq event-name (concat event-name "=")))
      
      (setq perf-cmd-line
	    (format "perf probe -a '%s%s:%d' --vmlinux=%s/%s"
		    event-name func-name func-offset
		    sjihs-btrfs-next-build-dir
		    sjihs-vmlinux-relative-path)))

    (when (or (equal probe-type '(4)) (equal probe-type '(16)))
      (message "%s" perf-cmd-line)
      (compile perf-cmd-line))

    ;; Probe with variable values to be collected
    (when (not (or (equal probe-type '(4)) (equal probe-type '(16))))
      (if (get-buffer "perf-edit-probe-vars")
	  (kill-buffer "perf-edit-probe-vars"))
      (setq perf-edit-probe-vars (get-buffer-create "perf-edit-probe-vars"))
      (let ((func-var-list (sjihs--perf-extract-var-list func-name func-offset)))
	(switch-to-buffer perf-edit-probe-vars)
	(sjihs-perf-probe-add-mode)
	(erase-buffer)
	(setq tabulated-list-entries nil)
	(dolist (func-var func-var-list)
	  (setq entry-vector (vector "N" (cdr func-var) (car func-var) "-" "-"))
	  (add-to-list 'tabulated-list-entries (list nil entry-vector)))

	(tabulated-list-print)
	(setq-local sjihs-func-name func-name)
	(setq-local sjihs-func-offset func-offset)))))
(global-set-key (kbd "C-c k p a") 'sjihs-perf-probe-add)

(defun sjihs--perf-probe-list ()
  (let ((probe-points ()))
    (dolist (probe (split-string
		    (shell-command-to-string "perf probe -l")
		    "\n"))
      (setq probe (replace-regexp-in-string "^[ \t]+" "" probe))
      (setq probe (car (split-string probe " ")))
      (add-to-list 'probe-points probe))
    probe-points))

(defun sjihs-perf-probe-list ()
  (interactive)
  (let ((probe-points (sjihs--perf-probe-list))
	(probe-list ""))
    (dolist (probe probe-points)
      (setq probe-list (concat probe-list probe "\n")))
    (message "Probe points:\n")
    (message "%s" probe-list)))
(global-set-key (kbd "C-c k p L") 'sjihs-perf-probe-list)

(defun sjihs-perf-probe-delete (probe-name)
  (interactive
   (list  (completing-read "Probe to delete: " (sjihs--perf-probe-list))))
  (compile (format "perf probe -d %s" probe-name)))
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
