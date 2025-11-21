(use-package format-all
  :ensure t
  :preface
  (defun fmt ()
    "format whole buffer"
    (interactive)
    (if (derived-mode-p 'prolog-mode)
	(prolog-indent-buffer)
      (format-all-buffer)))
  :config
  (add-hook 'before-save-hook
	    (lambda ()
	      (when paimacs-editor-auto-format
		(ignore-errors (fmt)))))
  (global-set-key (kbd "M-F") #'fmt)
  :hook
  (prog-mode . format-all-mode))

(defun fmt--expand-mode (mode)
  (let* ((base (symbol-name mode))
         (modes (list
                 (intern (format "%s-ts-mode" base))
                 (intern (format "%s-mode" base)))))
    (cl-remove-if-not #'fboundp modes)))

;;;###autoload
(defmacro fmt! (mode spec)
  "Install FORMAT-ALL formatter for MODE and MODE-ts-mode."
  (let* ((formatter (car spec))
         (args (cdr spec))
         (args (mapcar (lambda (a)
                         (if (symbolp a) (symbol-name a) a))
                       args)))
    `(dolist (m (fmt--expand-mode ',mode))
       (add-hook
        (intern (format "%s-hook" m))
        (lambda ()
          (setq-local format-all-formatters
                      `((,(capitalize ,(symbol-name mode))
                         (,',formatter ,@',args)))))))))

(provide 'paimacs-formatter)
