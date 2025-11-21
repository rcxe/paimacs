(setq init-start-time (current-time))

(set-display-table-slot standard-display-table 'truncation (make-glyph-code ?…))
(set-display-table-slot standard-display-table 'wrap (make-glyph-code ?–))

;;;###autoload
(defmacro theme! (name &rest settings)
  (declare (indent 1))
  (let ((fn-name (intern (format "theme-%s" name)))
        (theme-var (format "%s" name)))
    `(defun ,fn-name ()
       (interactive)
       ,@(mapcar
          (lambda (setting)
            (let ((key (car setting))
                  (val (cadr setting)))
              (if (eq key 'frame-background-mode)
                  `(setq frame-background-mode ,val)
                `(setq ,(intern (format "nano-color-%s" key))
                       ,val))))
          settings)
       (setq nano-theme-var ,theme-var)
       (paimacs-apply-theme))))

;;;###autoload
(defun paimacs-apply-theme ()
  (interactive)
  (setq nano-font-family-monospaced paimacs-ui-font-family
        nano-font-size paimacs-ui-font-size)
  (nano-refresh-theme))

;;;###autoload
(defun paimacs-apply-indent-settings ()
  (setq-default indent-tabs-mode (eq paimacs-editor-indent-style 'tabs)
                tab-width paimacs-editor-tab-width
                standard-indent paimacs-editor-tab-width))

;;;###autoload
(defun paimacs-apply-line-numbers ()
  (pcase paimacs-editor-line-numbers
    ('absolute
     (global-display-line-numbers-mode 1)
     (setq display-line-numbers-type 'absolute))
    ('relative
     (global-display-line-numbers-mode 1)
     (setq display-line-numbers-type 'relative))
    ('nil
     (global-display-line-numbers-mode -1))))

;;;###autoload
(defun paimacs-apply-settings ()
  (interactive)
  (paimacs-apply-theme)
  (paimacs-apply-indent-settings)
  (paimacs-apply-line-numbers))

(provide 'paimacs-appearance)
