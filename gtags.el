(setq sjihs-gtags-conf-variables
      '(sjihs-site-lisp sjihs-gtags-path))
(dolist (sjihs-var
	 sjihs-gtags-conf-variables)
  (when (not (boundp sjihs-var))
    (error "%s: %s variable not set" load-file-name (symbol-name sjihs-var))))

(when (file-exists-p sjihs-gtags-path)
  (add-to-list 'load-path sjihs-site-lisp)
  (require 'gtags)
  (require 'cc-mode))

(setq sjihs-tags 'sjihs-ctags)
(defun sjihs-toggle-tags ()
  (interactive)
  (require 'dired)
  (if (eq sjihs-tags 'sjihs-ctags)
      (progn
	(setq sjihs-tags 'sjihs-gtags)
	(define-key global-map (kbd "M-.") 'gtags-find-tag)
	(define-key global-map (kbd "C-x 4 .") 'gtags-find-tag-other-window)
	(define-key global-map (kbd "C-x 4 .") 'gtags-find-tag-other-window)
	(define-key global-map (kbd "M-,") 'gtags-find-rtag)
	(define-key global-map (kbd "M-,") 'gtags-find-rtag)
	(define-key global-map (kbd "M-*") 'gtags-pop-stack)
	(define-key global-map (kbd "M-*") 'gtags-pop-stack)
	(message "Now using GNU/Global"))
    (progn
      (setq sjihs-tags 'sjihs-ctags)
      (define-key global-map (kbd "M-.") 'find-tag)
      (define-key global-map (kbd "M-.") 'find-tag)
      (define-key global-map (kbd "C-x 4 .") 'find-tag-other-window)
      (define-key global-map (kbd "C-x 4 .") 'find-tag-other-window)
      (define-key global-map (kbd "M-,") 'tags-loop-continue)
      (define-key global-map (kbd "M-,") 'tags-loop-continue)
      (define-key global-map (kbd "M-*") 'pop-tag-mark)
      (define-key global-map (kbd "M-*") 'pop-tag-mark)
      (message "Now using Ctags"))))
(sjihs-toggle-tags)
