(require 'server)
(when (not (server-running-p))
  (server-start))
