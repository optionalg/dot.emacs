(vbe:require 'profile)

;; No .newsrc
(setq gnus-read-newsrc-file nil
      gnus-save-newsrc-file nil
      gnus-startup-file (nnheader-concat gnus-home-directory "newsrc"))

;; Search with nnir
(require 'nnir)

;; Servers to use
(setq gnus-select-method
      ;; Primary server: IMAP
      `(nnimap ""
	       (nnimap-address
		,(cond ((vbe:at 'orange) "depotmail.infra.b1.p.fti.net")
		       (t "imap.luffy.cx")))
	       (nnimap-authenticator login)
	       (nnir-search-engine imap)
	       (nnimap-stream
		,(cond ((vbe:at 'orange) 'ssl)
		       (t 'tls))))
      ;; Secondary servers
      gnus-secondary-select-methods (cond ((vbe:at 'orange) nil)
					  (t '((nntp "news.crans.org"))))
      message-send-mail-function 'message-send-mail-with-sendmail
      gnus-agent nil)
			 

;; How to archive sent messages
(setq gnus-message-archive-group '((unless (message-news-p)
				     (cond ((vbe:at 'orange) "INBOX.Sent")
					   (t "Sent"))))
      gnus-message-archive-method "nnimap:")

;; How to grab old articles
(setq gnus-refer-article-method
      '(current				; Local server first
	(nntp "news.gmane.org")))	; gmane


;; Scan news every 5 minutes if idle for more than 30 seconds
(gnus-demon-add-handler 'gnus-demon-scan-news 5 30)

(provide 'vbe:gnus/servers)
