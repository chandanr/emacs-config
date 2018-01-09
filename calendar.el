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

(setq holiday-other-holidays
      '((holiday-fixed 1 15 "Sankranti")
	(holiday-fixed 1 26 "Republic day")
	(holiday-fixed 5 1 "May day")
	(holiday-fixed 8 15 "Independence day")
	(holiday-fixed 8 22 "Bakrid")
	(holiday-fixed 9 13 "Ganesha Chaturthi")
	(holiday-fixed 10 2 "Gandhi Jayanthi")
	(holiday-fixed 10 19 "Vijaya Dashami")
	(holiday-fixed 11 1 "Kannada Rajyotsava")
	(holiday-fixed 11 6 "Deepavali")
	(holiday-fixed 12 25 "Christmas")))
