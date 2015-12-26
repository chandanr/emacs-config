;; GUD
;; Enable tooltip mode.
(gud-tooltip-mode)
;; Prevent GUD from trying to list all src files associated with a vmlinux.
(setq gdb-create-source-file-list nil)
;; Don't display the I/O buffer.
(setq gdb-use-separate-io-buffer nil)
;; Display all GUD windows.
(setq gdb-many-windows t)
;; Raise the watch expr Speedbar
(setq gdb-speedbar-auto-raise t)
;; Print de-referenced data.
(define-key gud-mode-map (kbd "C-x C-a C-z") 'gud-pstar)
(define-key gud-mode-map (kbd "C-c g d") 'gdb-display-disassembly-buffer)

;; Misc notes
;; C-x C-a C-w on the variable buffer line creates a watch point for the
;; variable. With a prefix, you can enter a variable name.

(custom-set-variables '(gdb-non-stop-setting nil t))
