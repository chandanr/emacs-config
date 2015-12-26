
;;; Documentation a.k.a Reminders

; file-paragraph (bound to M-q)
; To get info on a particular mode use the command C-h m

; Emacs recognizes many files already, but sometimes, you need to tell
; it to use some specific mode for a file. To do this, there is
; auto-mode-alist. Suppose, we want to use text-mode for all files with
; extension .foo or .bar; we add to our .emacs:
; (add-to-list 'auto-mode-alist
; ;        '("\\.foo$\\|.bar$" . text-mode))

; To display line number use "M-x linum"

; To learn about key bindings or existing key bindings use the
; following: C-h b (describe-bindings) and C-h k (describe-key)

; To change the color of a particular token (e.g string, comments, ...)
; 1. Place the point over the token.
; 2. Use the command M-x customize-face to change the color value assigned.

; To display colors execute the following command.
; list-colors-display

; Use M-x send-invisible to enter passwords.

; Highlight the current line.
; (global-hl-line-mode t)

; To edit a file in hexadecimal mode use the following command.
; M-x hexl-mode

; To check out the cvs status use the following command.
; M-x cvs-status

; Align variable and symbolic constant definitions
; Select the list of variables (or symoblic constants)
; and execute the command align-regexp on the selected
; region

; Easy buffer switching by holding down shift and press any arrow key.
; (windmove-default-keybindings 'shift)

; Show a marker in the left fringe for lines not in the buffer
; (setq default-indicate-empty-lines t)


; Use system trash (for emacs 23)
; (setq delete-by-moving-to-trash nil)

; M-i inserts a new tab.

; proced is a new process editor mode.

; To convert spaces to tabs use M-x tabify.
; To convert tabs to spaces use M-x untabify.

; The emacs interface commands for find and grep utilities are
; find-name-dired and find-grep-dired.

; Replace spaces with tabs using M-x tabify.
; Replace tabs with spaces using M-x untabify.

; fill-column is 'buffer local'. To set it for a particular buffer use
; C-u 70 C-x f. To change the global 'default value' use
; (setq-default fill-column size)

; To pretty print lisp objects (e.g. lists) use the following functions.
; pp, pp-eval-expression and pp-eval-last-sexp

; Evaluate a sexp interactively by typing M-: and then the sexp itself.

; C-c a # Lists stuck projects.

; When looking for a variable with an incomplete name, use 'M-x apropos-variable RET incomplete-name RET

; To display the contents of multiple directories in a single buffer in dired, type 'i' on a directory entry.

; C-c C-x C-k marks the current entry for agenda action. In the agenda buffer,
; with cursor on the selected date, type 'k s' (for schedule) or 'k d' (for dealine).

; M-x auto-revert-tail-mode provides the functionality of 'tail -f filename'






