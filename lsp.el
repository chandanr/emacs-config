(require 'lsp-mode)

(add-hook 'c-mode-common-hook 'lsp)
(add-hook 'c++-mode-hook 'lsp)
(add-hook 'python-mode-hook 'lsp)
(add-hook 'rust-mode-hook 'lsp)

(setq lsp-clients-clangd-args '("-j=4" "-log=error" "--background-index"))

(require 'company-lsp)
(push 'company-lsp company-backends)

