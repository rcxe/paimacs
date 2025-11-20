(use-package dashboard 
  :ensure t
  :if (< (length command-line-args) 2)
  :custom
  (dashboard-startup-banner (expand-file-name "marisa.png" user-emacs-directory))
  (dashboard-items '((recents . 5)))
  (dashboard-startupify-list '( dashboard-insert-banner
                                dashboard-insert-items
                                dashboard-insert-footer))
  (dashboard-center-content t)
  :config
  (add-hook 'elpaca-after-init-hook #'dashboard-insert-startupify-lists)
  (add-hook 'elpaca-after-init-hook #'dashboard-initialize)
  (dashboard-setup-startup-hook)
  (setq initial-buffer-choice (lambda () (get-buffer "*dashboard*"))))

(provide 'paimacs-dashboard)
