(defun sjihs-print-block-boundaries (page-start page-size block-size)
  (let ((page-end (1- (+ page-start page-size)))
	(block-start page-start)
	(output ""))

    (while (< block-start page-end)
      (setq output
	    (concat output
		    (format "%d - %d - "
			    block-start
			    (1- (+ block-start block-size)))))
      (setq block-start (+ block-start block-size)))
    output))
