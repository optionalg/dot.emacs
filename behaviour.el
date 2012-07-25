(setq mouse-yank-at-point t		; Yank where the point currently is
      mouse-1-click-follows-link nil	; Don't follow links with left click
      make-backup-files nil)		; Don't make backups, not used in ages

;; Always use y/n prompt
(fset 'yes-or-no-p 'y-or-n-p)
;; No dialog box
(setq use-dialog-box nil)
;; Auto revert (if no pending change, automatically revert a buffer)
(global-auto-revert-mode 1)

;; Various runtime directories
(setq url-cache-directory (vbe:run-directory "url")
      auto-save-list-file-prefix (format "%s/saves-"
					 (vbe:run-directory "auto-save"))
      tramp-persistency-file-name (format "%s/tramp-history"
					  (vbe:run-directory "tramp")))

;; Display colors with "colors"
(vbe:add-package '(:name "rainbow-mode"))

;; Which browser to use? x-www-browser.
(setq browse-url-browser-function 'browse-url-generic
      browse-url-generic-program "x-www-browser")

;; Enable some disabled commands
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)

(provide 'vbe:behaviour)
