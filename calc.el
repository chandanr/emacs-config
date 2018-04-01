(eval-after-load "calc-bin"
  '(calc-word-size 128))

(eval-after-load "calc-units"
  (progn
    (setq math-additional-units
	  '((GiB "1024 * MiB" "Giga Byte")
	    (MiB "1024 * KiB" "Mega Byte")
	    (KiB "1024 * B" "Kilo Byte")
	    (B nil "Byte")
	    (Gib "1024 * Mib" "Giga Bit")
	    (Mib "1024 * Kib" "Mega Bit")
	    (Kib "1024 * b" "Kilo Bit")
	    (b "B / 8" "Bit")))
    (setq math-units-table nil)))

