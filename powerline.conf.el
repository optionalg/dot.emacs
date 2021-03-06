;;; Powerline settings
;;; Code:

(powerline-default-theme)
(setq powerline-default-separator 'arrow
      powerline-display-buffer-size t
      powerline-display-hud nil)

;; Handle DPI change
(defun vbe/after-font-setting-change-default-font (display-or-frame set-font)
    (pl/reset-cache))
(advice-add 'font-setting-change-default-font
            :after #'vbe/after-font-setting-change-default-font)

;;; powerline.conf.el ends here
