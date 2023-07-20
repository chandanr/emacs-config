(require 'cc-mode)
(require 'subr-x)

(define-key c-mode-map (kbd "M-/") 'complete-tag)
(define-key c-mode-map (kbd "M-a") 'c-beginning-of-defun)
(define-key c-mode-map (kbd "M-e") 'c-end-of-defun)

(add-hook 'c-mode-common-hook
	  '(lambda ()
	     (c-toggle-hungry-state)))

(add-hook 'c-mode-common-hook
	  (lambda()
	    (local-set-key  (kbd "C-c o") 'ff-find-other-file)))

;; Highlight FIXME, TODO and BUG keywords
(add-hook 'c-mode-common-hook
	  (lambda ()
	    (font-lock-add-keywords
	     nil '(("\\<\\(FIXME\\|TODO\\|BUG\\|chandan\\):" 1 font-lock-warning-face t)))))

(defun sjihs-get-nth-line (line-number)
  (save-excursion
    (goto-line line-number)
    (buffer-substring-no-properties
     (line-beginning-position)
     (line-end-position))))

(defun sjihs-get-pos-column-number (pos)
  (save-excursion
    (goto-char pos)
    (current-column)))

(defun sjihs-align-below-condition-p (cond-stmt)
  (let ((align t))
    (when (string-match ".+\\(==\\|!=\\|\s&\\|\s^\\|\s|\\)\s*$" cond-stmt)
      (setq align nil))
    align))

(defun sjihs-compute-cond-stmt-indentation (anchor1 anchor2)
  (let (column1 column2 offset stmt)
    ;; First condition of if/while statement consists of a function
    ;; call.
    ;; We ignore the 2nd c-syntactic element
    (if (= (length c-syntactic-context) 2)
	(progn
	  (setq offset nil)
	  (when (eq c-syntactic-element (nth 0 c-syntactic-context))
	    (setq column1 (sjihs-get-pos-column-number anchor1))
	    (setq offset
		  (vector (+ column1 (* 2 c-basic-offset))))))

      (setq column1 (sjihs-get-pos-column-number anchor1))
      (setq column2 (sjihs-get-pos-column-number anchor2))
      (setq stmt (sjihs-get-nth-line (1- (line-number-at-pos))))
      (setq stmt (string-trim-right stmt))

      (if (sjihs-align-below-condition-p stmt)
	  (setq offset
		(vector (1+ column2)))
	(setq offset
	      (vector (+ column1 (* 2 c-basic-offset))))))
    offset))

(defun sjihs-compute-regular-stmt-indentation (anchor1)
  (let (column1 offset)
    (setq column1 (sjihs-get-pos-column-number anchor1))

    (when (% column1 c-basic-offset)
      (setq column1 (/ column1 c-basic-offset))
      (setq column1 (* column1 c-basic-offset)))

    (setq offset
	  (vector (+ column1 (* 2 c-basic-offset))))

    offset))

;; c-echo-syntactic-information-p
(defun sjihs-linux-set-arglist-cont-nonempty (ignored)
  (let ((anchor1 (c-langelem-pos c-syntactic-element))
	(anchor2 (c-langelem-2nd-pos c-syntactic-element))
	offset stmt)

    (setq stmt
	  (sjihs-get-nth-line (line-number-at-pos anchor1)))

    (if (string-match "[\s\t]+\\(if\\|while\\)\s*(.+" stmt)
	(setq offset (sjihs-compute-cond-stmt-indentation anchor1 anchor2))

      (setq offset (sjihs-compute-regular-stmt-indentation anchor1)))

    offset))

(c-add-style
 "xfs-linux"
 '("linux" (c-offsets-alist
	    (arglist-cont-nonempty . (first sjihs-linux-set-arglist-cont-nonempty)))))

(add-hook 'c-mode-hook
	  (lambda ()
	    (setq c-basic-offset 8
		  indent-tabs-mode t
		  fill-column 80
		  comment-style 'extra-line
		  c-echo-syntactic-information-p t)
	    (c-set-style "xfs-linux")))

;; Show unnecessary whitespace in a C source file.
(add-hook 'c-mode-hook
	  (lambda()
	    (setq whitespace-style
		  '(face trailing space-before-tab
			 space-after-tab indentation))
	    (whitespace-mode)))
