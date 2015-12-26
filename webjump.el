(require 'webjump)
(global-set-key (kbd "C-x g") 'webjump)
(add-to-list 'webjump-sites
	     '("Urban dictionary" .
	       [simple-query
		"www.urbandictionary.com""http://www.urbandictionary.com/define.php?term="""]))
