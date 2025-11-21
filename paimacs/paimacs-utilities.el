(use-package colorful-mode
			 :ensure t
			 :custom
			 (colorful-only-strings 'only-prog)
			 (colorful-use-prefix t)
			 (colorful-prefix-string "▪")
			 :config
			 (global-colorful-mode t))

(provide 'paimacs-utilities)
