;;; Org-mode configuration.

(setq sjihs-org-conf-variables
      '(sjihs-gtd-org-directory sjihs-gtd-org-agenda-files))

(dolist (sjihs-var
	 sjihs-org-conf-variables)
  (when (not (boundp sjihs-var))
    (error "%s: %s variable not set" load-file-name (symbol-name sjihs-var))))

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
      org-directory sjihs-gtd-org-directory
      org-agenda-files sjihs-gtd-org-agenda-files
      org-export-htmlize-output-type 'css
      org-clock-idle-time 10
      org-duration-format 'h:mm)


(setq org-clock-persist 'history)
(org-clock-persistence-insinuate)

(setq org-stuck-projects
      '("+LEVEL=2/-DONE-SOMEDAY_MAYBE"
	nil ;("NEXTACTION" "PROJECTS" "WAITING_FOR" "DELEGATED")
	nil
	"\\(SCHEDULED\\|DEADLINE\\)"))

(setq org-agenda-custom-commands
      '(("W" "Biweekly review"
	 agenda ""
	 ((org-agenda-tag-filter-preset '("+WORK"))
	  (org-agenda-start-on-weekday nil)
	  (org-agenda-time-grid nil)
	  (org-agenda-skip-scheduled-if-done nil)
	  (org-agenda-include-diary nil)
	  (org-agenda-log-mode-items '(state))
	  (org-agenda-files sjihs-gtd-org-agenda-files)
	  (org-agenda-span 14)
	  (org-agenda-start-day "-14d")
	  (org-agenda-archives-mode t)
	  (org-agenda-show-log nil)
	  (org-agenda-start-with-log-mode nil)
	  (org-agenda-overriding-header "Biweekly work review")))
	("w" tags-todo
	 "+WORK&+TODO={NEXTACTION\\|WAITING_FOR}&+SCHEDULED<=\"<today>\"")
	("h" tags-todo
	 "+HOME&+TODO={NEXTACTION\\|WAITING_FOR}&+SCHEDULED<=\"<today>\"")
	("o" tags-todo
	 "+OUTSIDE&+TODO={NEXTACTION\\|WAITING_FOR}&+SCHEDULED<=\"<today>\"")))

