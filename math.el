(defun sjihs-round-up-to-power-of-2 (src-num power-of-2)
  (interactive "nEnter number: \nnEnter power of 2: ")
  (let* ((nr-bits (truncate (log power-of-2 2)))
	 (mask (1- (lsh 1 nr-bits)))
	 (result (+ src-num mask)))
    (logand result (lognot mask))))
