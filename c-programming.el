(require 'cc-mode)
(require 'subr-x)

(define-key c-mode-map (kbd "M-/") 'complete-tag)
(define-key c-mode-map (kbd "M-a") 'c-beginning-of-defun)
(define-key c-mode-map (kbd "M-e") 'c-end-of-defun)

(defun c-lineup-arglist-tabs-only (ignored)
  "Line up argument lists by tabs, not spaces"
  (let* ((anchor (c-langelem-pos c-syntactic-element))
	 (column (c-langelem-2nd-pos c-syntactic-element))
	 (offset (- (1+ column) anchor))
	 (steps (floor offset c-basic-offset)))
    (* (max steps 1)
       c-basic-offset)))

(add-hook 'c-mode-common-hook
          (lambda ()
            ;; Add kernel style
            (c-add-style
             "linux-tabs-only"
             '("linux" (c-offsets-alist
                        (arglist-cont-nonempty
                         c-lineup-gcc-asm-reg
                         c-lineup-arglist-tabs-only))))
	    (setq fill-column 80)))

(add-hook 'c-mode-hook
          (lambda ()
            ;; (let ((filename (buffer-file-name)))
              ;; Enable kernel mode for the appropriate files
              ;; (when (and filename
              ;;            (string-match (expand-file-name "~/src/linux-trees")
              ;;                          filename))
	    (setq indent-tabs-mode t)
	    (c-set-style "linux-tabs-only")))

(add-hook 'c-mode-common-hook
         '(lambda ()
            (c-toggle-hungry-state)))

(add-hook 'c-mode-common-hook
	  (lambda()
	    (local-set-key  (kbd "C-c o") 'ff-find-other-file)))

;; Highlight FIXME, TODO and BUG keywords
(add-hook 'c-mode-common-hook
	  (lambda ()
	    (font-lock-add-keywords
	     nil '(("\\<\\(FIXME\\|TODO\\|BUG\\|chandan\\):" 1 font-lock-warning-face t)))))

;; Show unnecessary whitespace in a C source file.
(add-hook 'c-mode-hook
	  (lambda()
	    (setq whitespace-style
		  '(face trailing space-before-tab
			 space-after-tab indentation))
	    (whitespace-mode)))

;; (setq comment-style 'multi-line)
(setq comment-style 'extra-line)
