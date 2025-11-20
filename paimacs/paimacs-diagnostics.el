(use-package sideline
  :ensure t
  :hook (flymake-mode . sideline-mode)
  :init
  (setq sideline-backends-right '(sideline-flymake)))

(use-package sideline-flymake
  :ensure t
  :init
  (setq sideline-flymake-display-mode 'line))

(provide 'paimacs-diagnostics)
