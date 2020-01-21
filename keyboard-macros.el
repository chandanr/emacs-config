(fset 'sjihs-edit-generic
   [?\C-s ?g ?e ?n ?e ?r ?i ?c ?\C-s ?\M-b return])

(fset 'sjihs-edit-xfs
   [?\C-s ?x ?f ?s ?\C-s ?\M-b return])

(fset 'sjihs-edit-ext4
   (lambda (&optional arg) "Keyboard macro." (interactive "p") (kmacro-exec-ring-item (quote ([19 101 120 116 52 19 134217826 return] 0 "%d")) arg)))
