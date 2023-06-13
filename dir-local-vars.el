(setq sjihs-dir-local-vars-conf-variables
      '(sjihs-xfstests-dir))

(dolist (sjihs-var
	 sjihs-dir-local-vars-conf-variables)
  (when (not (boundp sjihs-var))
    (error "%s: %s variable not set" load-file-name (symbol-name sjihs-var))))

(dir-locals-set-class-variables
 'shell-scripts-directory
 '((nil . ((mode . shell-script)))))

(setq sjihs-xfstests-dir (concat sjihs-xfstests-dir "/common"))

(dolist (d (list sjihs-xfstests-dir))
  (dir-locals-set-directory-class d 'shell-scripts-directory))

