(setq sjihs-gtags-conf-variables
      '(sjihs-gtags-path))
(dolist (sjihs-var
	 sjihs-gtags-conf-variables)
  (when (not (boundp sjihs-var))
    (error "%s: %s variable not set" load-file-name (symbol-name sjihs-var))))

(require 'helm-gtags)

;; Enable helm-gtags-mode
(add-hook 'c-mode-hook 'helm-gtags-mode)
(add-hook 'c++-mode-hook 'helm-gtags-mode)
(add-hook 'asm-mode-hook 'helm-gtags-mode)

(define-key helm-gtags-mode-map (kbd "M-.") 'helm-gtags-find-tag)
(define-key helm-gtags-mode-map (kbd "M-,") 'helm-gtags-find-rtag)
(define-key helm-gtags-mode-map (kbd "M-s") 'helm-gtags-find-symbol)
(define-key helm-gtags-mode-map (kbd "M-g M-p") 'helm-gtags-parse-file)
(define-key helm-gtags-mode-map (kbd "C-c <") 'helm-gtags-previous-history)
(define-key helm-gtags-mode-map (kbd "C-c >") 'helm-gtags-next-history)
(define-key helm-gtags-mode-map (kbd "M-*") 'helm-gtags-pop-stack)


