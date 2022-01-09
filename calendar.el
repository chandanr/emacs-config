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
      '((holiday-fixed 1 14 "Makara Sankranti")
	(holiday-fixed 1 26 "Republic day")
	(holiday-fixed 3 18 "Holi")
	(holiday-fixed 4 15 "Ugadi")
	(holiday-fixed 5 1 "May day")
	(holiday-fixed 5 3 "Ramzan")
	(holiday-fixed 8 15 "Independence day")
	(holiday-fixed 8 31 "Ganesh Chaturthi")
	(holiday-fixed 10 2 "Gandhi Jayanti")
	(holiday-fixed 10 5 "Dussera")
	(holiday-fixed 10 24 "Deepavali")
	(holiday-fixed 10 25 "Deepavali")
	(holiday-fixed 11 1 "Karnataka rajyotsava")
	(holiday-fixed 10 24 "Deepavali")))
