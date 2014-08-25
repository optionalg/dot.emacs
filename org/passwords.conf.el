;;; Code:

(require 'org-passwords)
(setq org-passwords-file "~/Documents/org/passwords.gpg"
      org-passwords-random-words-dictionary "/usr/share/dict/american-english"
      org-passwords-time-opened "5 min")

(define-key org-passwords-mode-map
  (kbd "C-c u")
  'org-passwords-copy-username)
(define-key org-passwords-mode-map
  (kbd "C-c s")
  'org-passwords-copy-password)
(define-key org-passwords-mode-map
  (kbd "C-c g")
  'org-passwords-open-url)

;;; passwords.conf.el ends here
