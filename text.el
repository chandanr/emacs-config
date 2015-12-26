;;; Text mode
(add-hook 'text-mode-hook
	  (lambda()
	    (set-fill-column 78)   ; buffer-local variable; wrap at col 78
	    (auto-fill-mode t)))   ; wrap around automagically
