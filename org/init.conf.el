(require 'dash)
(require 's)

;; Agenda files are subdirectories of a given directory
(setq org-agenda-files
      (let ((base (file-name-as-directory (expand-file-name "~/Documents/org"))))
        (--filter (not (file-exists-p (concat it "/.disabled")))
                  (--map (concat base it)
                         (-difference
                          (--map (nth 0 it)
                                 (--filter (nth 1 it) (directory-files-and-attributes base)))
                          '("." ".."))))))

;; Disable C-c [ and C-c ] and C-c ; in org-mode. We want to keep the
;; list of agenda files as defined above.
(add-hook 'org-mode-hook
          '(lambda ()
             ;; Undefine C-c [ and C-c ] since this breaks my
             ;; org-agenda files when directories are include It
             ;; expands the files in the directories individually
             (org-defkey org-mode-map "\C-c["    'undefined)
             (org-defkey org-mode-map "\C-c]"    'undefined)
             (org-defkey org-mode-map "\C-c;"    'undefined))
          'append)

(setq
 org-completion-use-ido t               ; use IDO for completion
 org-startup-indented t                 ; indent by default
 org-tags-column -70                    ; align tags on the 70th columns
 org-hide-leading-stars t               ; don't show leading stars
 org-cycle-separator-lines 0            ; don't show blank lines between collapsed trees
 org-src-fontify-natively t             ; fontify code blocks
 org-edit-src-content-indentation 0     ; don't indent source blocks
 org-catch-invisible-edits 'error       ; don't edit invisible text
)

;; Todo keywords
(setq org-todo-keywords
      '((sequence "TODO(t)" "NEXT(n)" "PROGRESS(p)" "|" "DONE(d!)")
        (sequence "WAITING(w@/!)" "HOLD(h@/!)" "|" "CANCELLED(c@/!)"))
      org-todo-keyword-faces
      `(("TODO"
         :box (:line-width 1 :color ,(naquadah-get-colors 'scarlet-red-1))
         :background ,(naquadah-get-colors 'scarlet-red-3)
         :foreground "white"
         :weight bold)
        ("NEXT"
         :box (:line-width 1 :color ,(naquadah-get-colors 'sky-blue-1))
         :background ,(naquadah-get-colors 'sky-blue-3)
         :foreground "white"
         :weight bold)
        ("PROGRESS"
         :box (:line-width 1 :color ,(naquadah-get-colors 'chocolate-1))
         :background ,(naquadah-get-colors 'chocolate-3)
         :foreground "white"
         :weight bold)
        ("DONE"
         :box (:line-width 1 :color ,(naquadah-get-colors 'chameleon-1))
         :background ,(naquadah-get-colors 'chameleon-3)
         :foreground "white"
         :weight bold)
        ("WAITING"
         :box (:line-width 1 :color ,(naquadah-get-colors 'orange-1))
         :background ,(naquadah-get-colors 'orange-3)
         :foreground "white"
         :weight bold)
        ("HOLD"
         :box (:line-width 1 :color ,(naquadah-get-colors 'plum-1))
         :background ,(naquadah-get-colors 'plum-3)
         :foreground "white"
         :weight bold)
        ("CANCELLED"
         :box (:line-width 1 :color ,(naquadah-get-colors 'aluminium-3))
         :background ,(naquadah-get-colors 'aluminium-5)
         :foreground "white"
         :weight bold)))

;; Use bullets
(require 'org-bullets)
(add-hook 'org-mode-hook
          '(lambda ()
             (org-bullets-mode 1)))

;; Babel
(org-babel-do-load-languages 'org-babel-load-languages
                             '((ledger . t)))
(setq org-confirm-babel-evaluate '(lambda (lang body)
                                    (not (string= lang "ledger"))))

;; Autocommit in git
(defun vbe:org-git-auto-commit ()
  "Autocommit the current buffer if this is an org buffer"
  (let ((filename (buffer-file-name)))
    (when (--any? (and (file-directory-p it)
                       (s-starts-with? (file-name-as-directory it)
                                       filename))
                  org-agenda-files)
      (shell-command (concat "git add " filename
                             " && git commit -m Autocommit")))))
(add-hook 'after-save-hook 'vbe:org-git-auto-commit)

(require 'org-protocol)
(require 'org-mime)