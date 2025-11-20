(use-package nerd-icons
  :ensure t)

(use-package dirvish
  :ensure t
  :bind
  ("C-c d" . dirvish-side)
  :custom
  (dirvish-attributes '(vc-state subtree-state nerd-icons collapse file-size))
  (dirvish-subtree-state-style 'nerd)
  :config
  (dirvish-override-dired-mode))

(provide 'paimacs-files)
