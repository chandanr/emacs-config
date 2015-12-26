;;; Org-mode configuration.
(require 'org)
;(require 'ox-beamer)
;(require 'org-install)

(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-cc" 'org-capture)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cb" 'org-iswitchb)

;; Disable subscripting when two words are separated using underscores.
(setq org-export-with-sub-superscripts nil
      org-hide-leading-stars t
      org-clock-persist t
      org-startup-align-all-tables t
      org-enforce-todo-dependencies t
      org-agenda-dim-blocked-tasks t
      org-hierarchical-todo-statistics nil
      org-agenda-skip-scheduled-if-done t
      org-clock-persist 'history
      org-agenda-span 'day
      org-return-follows-link t
      org-log-into-drawer t
      org-directory "~/google-drive/documents/gtd"
      org-agenda-files (list "~/google-drive/documents/gtd/gtd.txt")
      org-export-htmlize-output-type 'css)

(setq org-clock-persist 'history)
(org-clock-persistence-insinuate)

(setq org-stuck-projects
      '("+LEVEL=2/-DONE-SOMEDAY_MAYBE"
	nil ;("NEXTACTION" "PROJECTS" "WAITING_FOR" "DELEGATED")
	nil
	"\\(SCHEDULED\\|DEADLINE\\)"))
