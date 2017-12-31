(custom-set-variables
 '(graphviz-dot-preview-extension "png"))

(defun sjihs-compile-on-save ()
  (add-hook
   'after-save-hook
   (lambda ()
     (save-window-excursion
       (compile compile-command))) t t))

(add-hook 'graphviz-dot-mode-hook 'sjihs-compile-on-save)
