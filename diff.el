(add-hook 'diff-mode-hook
	  (lambda ()
	    (save-excursion
	      (goto-char (point-min))
	      (while (not (eobp))
		(diff-hunk-next)))))

(setq ediff-split-window-function 'split-window-vertically
      ediff-window-setup-function 'ediff-setup-windows-plain)

