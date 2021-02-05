(require 'mu4e)
(require 's)

(setq sjihs-mu4e-conf-variables
      '(sjihs-patch-review-directory))

(dolist (sjihs-var
	 sjihs-mu4e-conf-variables)
  (when (not (boundp sjihs-var))
    (error "%s: %s variable not set" load-file-name (symbol-name sjihs-var))))

;; use mu4e for e-mail in emacs
(setq mail-user-agent 'mu4e-user-agent)

(setq mu4e-maildir "/home/chandan/mail/open-source/")
(setq mu4e-drafts-folder "/Drafts")
(setq mu4e-sent-folder   "/Sent")
(setq mu4e-trash-folder  "/Trash")

;; don't save message to Sent Messages, Gmail/IMAP takes care of this
(setq mu4e-sent-messages-behavior 'delete)

;; (See the documentation for `mu4e-sent-messages-behavior' if you have
;; additional non-Gmail addresses and want assign them different
;; behavior.)

;; setup some handy shortcuts
;; you can quickly switch to your Inbox -- press ``ji''
;; then, when you want archive some messages, move them to
;; the 'All Mail' folder by pressing ``ma''.

(setq mu4e-maildir-shortcuts
      '(("/INBOX" . ?i)
	("/Sent" . ?s)
	("/Spam" . ?p)
	("/Trash" . ?t)
	("/linux-mm" . ?m)
	("/linux-btrfs" . ?b)
	("/linux-bcachefs" . ?c)
	("/linux-xfs" . ?x)
	("/linux-block" . ?l)
	("/fstests" . ?f)
	("/linux-next" . ?n)))

;; allow for updating mail using 'U' in the main view:
(setq mu4e-get-mail-command "/home/chandan/bin/sync-email.sh")

;; something about ourselves
(setq
   user-mail-address "chandanrlinux@gmail.com"
   user-full-name  "Chandan Babu R"
   mu4e-compose-signature (concat "chandan\n")
   mu4e-view-auto-mark-as-read nil
   mu4e-change-filenames-when-moving t)

;; sending mail -- replace USERNAME with your gmail username
;; also, make sure the gnutls command line utils are installed
;; package 'gnutls-bin' in Debian/Ubuntu

(require 'smtpmail)
(setq message-send-mail-function 'smtpmail-send-it
      smtpmail-stream-type 'starttls
      starttls-use-gnutls t
      smtpmail-starttls-credentials '(("smtp.gmail.com" 587 nil nil))
      smtpmail-auth-credentials
      '(("smtp.gmail.com" 587 "chandanrlinux@gmail.com" nil))
      smtpmail-default-smtp-server "smtp.gmail.com"
      smtpmail-smtp-server "smtp.gmail.com"
      smtpmail-smtp-service 587)

;; don't keep message buffers around
(setq message-kill-buffer-on-exit t)

;; Header view configuration
(setq mu4e-headers-date-format "%d/%m/%Y %H:%M:%S")
(setq mu4e-headers-fields
      '((:date . 19)
	(:flags . 6)
	(:from . 22)
	(:subject)))

(setq message-citation-line-format "On %d %b %Y at %R, %f wrote:")
(setq message-citation-line-function 'message-insert-formatted-citation-line)

(require 'mu4e-actions)

(defun mu4e-save-mail-as-mbox (msg)
  (let ((path-name (mu4e-message-field msg :path))
	(subject (mu4e-message-field msg :subject))
	destdir destfile patch-file)
    (setq destdir
	  (read-directory-name "Enter destination directory: "
			       sjihs-patch-review-directory))
    (setq subject (s-replace "/" "_" subject))
    (setq subject (s-replace "[" "" subject))
    (setq subject (s-replace "]" "" subject))
    (setq subject (s-replace ":" "" subject))
    (setq subject (s-replace " " "_" subject))
    (setq subject (s-downcase subject))
    (setq destfile (concat destdir "/" subject ".mbox"))

    (copy-file path-name destfile)
    (message "Saved file as %s" destfile)))

(add-to-list 'mu4e-view-actions
	     '("Save mail as mbox" . mu4e-save-mail-as-mbox) t)
(add-to-list 'mu4e-view-actions
	     '("GitApply" . mu4e-action-git-apply-patch) t)
(add-to-list 'mu4e-view-actions
	     '("MboxGitApply" . mu4e-action-git-apply-mbox) t)

(setq mu4e-bookmarks
      (list
       (make-mu4e-bookmark
	:name "Unread msgs on linux-xfs"
	:query "list:linux-xfs.vger.kernel.org and flag:unread"
	:key ?x)))

;; mu4e-headers-toggle-full-search
