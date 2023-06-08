;;; Lisp
(require 'elisp-mode)
(require 'lisp-mode)

; Toggle echo area display of Lisp objects at point.
(add-hook 'emacs-lisp-mode-hook
	  (lambda ()
	    (eldoc-mode 1)))

(add-hook 'lisp-mode-hook
	  (lambda ()
	    (local-set-key (kbd "RET") 'newline-and-indent)
	    (setq fill-column 80
		  whitespace-style
		  '(face trailing space-before-tab
			 space-after-tab indentation))
	    (whitespace-mode)))

(add-hook 'emacs-lisp-mode-hook
	  (lambda ()
	    (local-set-key (kbd "RET") 'newline-and-indent)
	    (setq fill-column 80
		  whitespace-style
		  '(face trailing space-before-tab
			 space-after-tab indentation))
	    (whitespace-mode)))
