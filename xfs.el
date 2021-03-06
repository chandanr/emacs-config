(require 'calc-ext)

(defun xfs-compute-max-btree-height (total-leaf-recs leaf-min-recs node-min-recs)
  (let (nr-blks
	expr
	(nr-levels 1))

    (setq total-leaf-recs (number-to-string total-leaf-recs))
    (setq leaf-min-recs (number-to-string leaf-min-recs))
    (setq node-min-recs (number-to-string node-min-recs))

    (setq expr (concat total-leaf-recs "+" leaf-min-recs "- 1"))
    (setq nr-blks (calc-eval expr))

    (setq expr (concat "idiv(" nr-blks "," leaf-min-recs ")"))
    (setq nr-blks (calc-eval expr))

    (message "nr-levels = %d; nr-leaf-blks = %s;" nr-levels nr-blks)

    (while (progn
	     (setq nr-levels (1+ nr-levels))

	     (setq expr (concat "idiv(" nr-blks "," node-min-recs ")"))
	     (setq nr-blks (calc-eval expr))

	     (message "nr-levels = %d; nr-blks = %s;"
		      nr-levels
		      (if (= (string-to-number nr-blks) 0)
			  "1"
			nr-blks))

	     (math-lessp 0 (string-to-number nr-blks))))

    (message "Height of tree = %s" nr-levels)

    nr-levels))

(defun xfs-compute-max-btree-blocks (total-leaf-recs leaf-min-recs node-min-recs)
  (let (nr-blks
	(total-nr-blks)
	expr
	(nr-levels 1))

    (setq total-leaf-recs (number-to-string total-leaf-recs))
    (setq leaf-min-recs (number-to-string leaf-min-recs))
    (setq node-min-recs (number-to-string node-min-recs))

    (setq expr (concat total-leaf-recs "+" leaf-min-recs "- 1"))
    (setq nr-blks (calc-eval expr))

    (setq expr (concat "idiv(" nr-blks "," leaf-min-recs ")"))
    (setq nr-blks (calc-eval expr))
    (setq total-nr-blks nr-blks)

    (message "nr-levels = %d; nr-leaf-blks = %s;" nr-levels nr-blks)

    (while (progn
	     (setq nr-levels (1+ nr-levels))

	     (setq expr (concat "idiv(" nr-blks "," node-min-recs ")"))
	     (setq nr-blks (calc-eval expr))
	     (setq total-nr-blks (calc-eval (concat total-nr-blks "+" nr-blks)))

	     (message "nr-levels = %d; nr-blks = %s; total-nr-blks = %s"
		      nr-levels
		      (if (= (string-to-number nr-blks) 0)
			  "1"
			nr-blks)
		      total-nr-blks)

	     (math-lessp 0 (string-to-number nr-blks))))

    (message "Height of tree = %s" nr-levels)
    (calc-sci-notation 1)
    (calc-eval (concat total-nr-blks "/" "1.0"))))
