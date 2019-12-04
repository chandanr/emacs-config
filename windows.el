;;; Windows configuration
; Get back your delicately configured emacs windows.
(winner-mode 1)
(windmove-default-keybindings)
; Use control-arrow keys for window resizing
(global-set-key (kbd "C-<right>") 'enlarge-window-horizontally)
(global-set-key (kbd "C-<left>") 'shrink-window-horizontally)

;; Move b/w buffers by holding shift and an arrow key.
(windmove-default-keybindings 'shift)

(global-set-key (kbd "C-c f") 'set-frame-name)
(global-set-key (kbd "C-x f") 'select-frame-by-name)

;; horizontal split.
;; (setq split-width-threshold nil)
;; vertical split.
;; (setq split-width-threshold 1)

(require 'window-numbering)
;; highlight the window number in pink color
(window-numbering-mode 1)
(add-hook 'minibuffer-setup-hook
	  'window-numbering-update)
(add-hook 'minibuffer-exit-hook
	  'window-numbering-update)

;; Toggle between split windows and a single window
(setq sjihs-window-configuration nil)
(defun toggle-windows-split ()
  "Switch back and forth between one window and whatever split
of windows we might have in the frame. The idea is to maximize
the current buffer, while being able to go back to the previous
split of windows in the frame simply by calling this command again."
  (interactive)
  (if (not (window-minibuffer-p (selected-window)))
      (progn
        (if (> (count-windows) 1)
	    (progn
              (setq sjihs-window-configuration (current-window-configuration))
              (delete-other-windows))
	  (when (not (equal sjihs-window-configuration nil))
	    (set-window-configuration sjihs-window-configuration))))))
(global-set-key (kbd "C-\\") 'toggle-windows-split)

(defun toggle-current-window-dedication ()
  (interactive)
  (let* ((window    (selected-window))
        (dedicated (window-dedicated-p window)))
   (set-window-dedicated-p window (not dedicated))
   (message "Window %sdedicated to %s"
            (if dedicated "no longer " "")
            (buffer-name))))
(global-set-key (kbd "<pause>") 'toggle-current-window-dedication)
