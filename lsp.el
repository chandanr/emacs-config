(require 'lsp-mode)

(add-hook 'c-mode-common-hook 'lsp)
(add-hook 'c++-mode-hook 'lsp)
(add-hook 'python-mode-hook 'lsp)
(add-hook 'rust-mode-hook 'lsp)

(setq lsp-clients-clangd-args '("-j=4" "-log=error" "--background-index"))

(require 'helm-xref)
(define-key prog-mode-map (kbd "M-.") 'xref-find-definitions)
(define-key prog-mode-map (kbd "C-M-.") 'xref-find-apropos)
(define-key prog-mode-map (kbd "M-,") 'xref-find-references)
(define-key prog-mode-map (kbd "M-*") 'xref-pop-marker-stack)
;; (define-key prog-mode-map (kbd "M-.") 'lsp-find-definitions)
;; (define-key prog-mode-map (kbd "C-M-.") 'xref-find-apropos)
;; (define-key prog-mode-map (kbd "M-,") 'lsp-find-references)

(setq lsp-diagnostics-provider :none)
(setq lsp-enable-snippet nil)
