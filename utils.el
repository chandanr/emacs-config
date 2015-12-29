(defun sjihs-file-basename (file)
  (file-name-nondirectory (directory-file-name file)))

(defun sjihs-file-dirname (file)
    (file-name-directory (directory-file-name file)))
