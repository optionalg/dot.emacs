;; Use lambda instead of anonymous function
(font-lock-add-keywords
 'js-mode `(("\\(function\\) *\\*?("
             (0 (progn (compose-region (match-beginning 1)
                                       (match-end 1) "\u0192")
                       nil)))))

;; Use right arrow for returns
(font-lock-add-keywords
 'js-mode `(("function *([^)]*) *{ *\\(return\\) "
             (0 (progn (compose-region (match-beginning 1)
                                       (match-end 1) "\u2190")
                       nil)))))