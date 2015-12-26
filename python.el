;; Python

(add-hook 'python-mode 'whitespace-mode)

(defun lookup-python-doc ()
  (interactive)
  (let (search-url keyword)
    (setq keyword
	  (if (region-active-p)
	      (buffer-substring-no-properties (region-beginning) (region-end))
	    (thing-at-point 'symbol)))
    (message "%s"
    (setq search-url
	  (format
	   "file:///usr/share/doc/python-docs-2.7.5/html/search.html?q=%s&check_keywords=yes&area=default"
	   keyword)))
    (browse-url search-url)))
(global-set-key (kbd "<f6>") 'lookup-python-doc)
