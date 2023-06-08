;;; Shell scripting settings
(require 'sh-script)

(setq sh-basic-offset 8
      sh-indentation 8)
(setq
 magic-mode-alist (cons '("^##/bin/bash$" . shell-script-mode) magic-mode-alist)
 sh-shell-file "/bin/bash")

(global-set-key (kbd "<f3>") 'eshell)

(add-hook 'sh-mode-hook
	  (lambda ()
	    (setq fill-column 80)))
