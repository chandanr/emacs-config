;;; Lisp
(require 'elisp-mode)
(require 'lisp-mode)

; Toggle echo area display of Lisp objects at point.
(add-hook 'emacs-lisp-mode-hook
	  (lambda ()
	    (eldoc-mode 1)))

(add-hook 'lisp-mode-hook
	  '(lambda ()
	     (local-set-key (kbd "RET") 'newline-and-indent)))

(add-hook 'emacs-lisp-mode-hook
	  '(lambda ()
	     (local-set-key (kbd "RET") 'newline-and-indent)))
