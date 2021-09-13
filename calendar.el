;;; Calendar/Holidays
(setq calendar-week-start-day 1)
(setq calendar-mark-holidays-flag t)
(setq holiday-general-holidays nil
      holiday-solar-holidays nil
      holiday-bahai-holidays nil
      holiday-christian-holidays nil
      holiday-hebrew-holidays nil
      holiday-islamic-holidays nil
      holiday-oriental-holidays nil
      holiday-other-holidays nil)

(setq calendar-latitude 12.976750
      calendar-longitude 77.575279)

(setq holiday-other-holidays
      '((holiday-fixed 10 15 "Vijayadashami")
	(holiday-fixed 11 1 "Karnataka Rajyotsava")
	(holiday-fixed 11 4 "Deepavali")
	(holiday-fixed 11 5 "Deepavali")
	(holiday-fixed 12 25 "Christmas")))
