;;; Commentary

;; This is an attempt to mimic \\[org-edit-src-code] on a
;; region. Unfortunately, the code from `org-mode' is not flexible
;; enough to be reused.
;;
;; The user selects a region and invoke
;; \\[vbe:edit-region-in-another-buffer]. The content of the region
;; will be copied to another buffer. Any left margin is removed. When
;; finished, the content of the buffer is copied back and the left
;; margin is restored. When no mode is specified, auto-detection is
;; attempted, otherwise the provided major mode is loaded.
;;
;; Also note that Emacs comes with an amazing feature called "indirect
;; buffers". This could simplify a lot our use case. See this blog post:
;;  http://demonastery.org/2013/04/emacs-narrow-to-region-indirect/
;;
;; The drawback is that you cannot narrow to a rectangle, so if there
;; is a left margin, you are out of luck. Hence the complicate code
;; below.

;;; Code:

(require 's)
(require 'dash)

(defvar vbe:edit-region-mode-map (make-sparse-keymap))
(define-key vbe:edit-region-mode-map "\C-xk" 'vbe:edit-region-exit)
(define-minor-mode vbe:edit-region-mode
  "Minor mode to edit region with another mode")

(defun vbe:edit-region-in-another-buffer (start end &optional arg)
  "Edit region in another buffer.

This could have been done with just an indirect buffer and
narrowing but we want to remove and restore any indentation. For
example, this allows one to edit a block literal in YAML. Can
specify a mode to use."
  (interactive "r\nP")
  (let* ((mode (if arg (intern (completing-read
                                "Mode: "
                                (mapcar (lambda (e) (list (symbol-name e)))
                                        (apropos-internal "-mode$" 'commandp))
                                nil t))
                 nil))
         (wincfg (current-window-configuration))
         (code (buffer-substring-no-properties start end))
         (left-margin (vbe:compute-left-margin code))
         (original (current-buffer))
         (buffer (generate-new-buffer
                  (format "*partial edition of %s*" (buffer-name))))
         ovl margin)

    ;; Setup an overlay
    (setq ovl (make-overlay start end))
    (overlay-put ovl 'face 'secondary-selection)
    (overlay-put ovl :read-only "Leave me alone")

    ;; Add current shortcut to \\[vbe:edit-region-mode-map]
    (let ((current-key (where-is-internal 'vbe:edit-region-in-another-buffer)))
      (when current-key
        (define-key vbe:edit-region-mode-map (car current-key)
          'vbe:edit-region-exit)))

    ;; Create a new buffer with the appropriate content
    (with-current-buffer buffer
      (insert code)
      (indent-rigidly (point-min) (point-max) (* left-margin -1))
      (if mode
          (funcall mode)
        (set-auto-mode))
      (goto-char (point-min))

      ;; Set some variables to restore situation
      (setq-local vbe:edit-region--start start)
      (setq-local vbe:edit-region--end end)
      (setq-local vbe:edit-region--ovl ovl)
      (setq-local vbe:edit-region--original original)
      (setq-local vbe:edit-region--left-margin left-margin)
      (setq-local vbe:edit-region--wincfg wincfg)

      ;; Remove file name to not allow saving
      (setq buffer-file-name nil)

      ;; Set minor mode
      (vbe:edit-region-mode))
    (pop-to-buffer buffer)
    (message (substitute-command-keys
              "Edit, then exit with \\[vbe:edit-region-exit]"))))

(defun vbe:compute-left-margin (code)
  "Compute left margin of a string of code."
  (-min
   (-map #'(lambda (line) (length (car (s-match "^\\s-*" line))))
         (-remove 's-blank? (s-lines code)))))

(defun vbe:edit-region-exit ()
  "Exit edition of region in buffer."
  (interactive)
  (let ((start vbe:edit-region--start)
        (end vbe:edit-region--end)
        (ovl vbe:edit-region--ovl)
        (original vbe:edit-region--original)
        (left-margin vbe:edit-region--left-margin)
        (wincfg vbe:edit-region--wincfg)
        code)
    (indent-rigidly (point-min) (point-max) left-margin)
    (setq code (buffer-substring-no-properties (point-min) (point-max)))
    (with-current-buffer original
      (save-excursion
        (delete-overlay ovl)
        (delete-region start end)
        (goto-char start)
        (insert code)))
    (set-buffer-modified-p nil)
    (kill-buffer (current-buffer))
    (switch-to-buffer original)
    (when wincfg
      (set-window-configuration wincfg))))

(provide 'vbe/edit-region)
;;; vbe-edit-region ends here
