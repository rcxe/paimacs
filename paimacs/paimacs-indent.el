(setq-default indent-tabs-mode t
              tab-width 4
              standard-indent 4)
(setq tab-always-indent t)

(use-package dtrt-indent
  :ensure t
  :hook (prog-mode . dtrt-indent-mode))

(use-package indent-bars
	:ensure t
	:custom
	(indent-bars-treesit-support t)
	:hook (prog-mode . indent-bars-mode))

(electric-pair-mode 0)

(provide 'paimacs-indent)
