(setq-default indent-tabs-mode t
              tab-width 2
              standard-indent 2)
(setq tab-always-indent t)

(use-package dtrt-indent
  :ensure t
  :hook (prog-mode . dtrt-indent-mode))

(electric-pair-mode 1)

(provide 'paimacs-indent)
