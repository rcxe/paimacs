(use-package sideline
  :ensure t
  :hook (prog-mode . sideline-mode)
  :init
  (setq sideline-truncate t)
  (setq sideline-backends-right '(sideline-blame sideline-flymake)))

(use-package sideline-blame :ensure t)

(use-package sideline-flymake
  :ensure t
  :init
  (setq sideline-flymake-display-mode 'line))

(provide 'paimacs-diagnostics)
