(use-package eglot
  :hook
  (prog-mode . eglot-ensure)
  :custom
  (eglot-events-buffer-size 0)
  (eglot-sync-connect t)
  (eglot-autoshutdown t)
  (eglot-report-progress t)
  (eglot-extend-to-xref t)
  :bind (:map eglot-mode-map
              ("C-c l r" . eglot-rename)
              ("C-c l a" . eglot-code-actions)
              ("C-c l f" . eglot-format)
              ("C-c l F" . eglot-format-buffer)
              ("C-c l d" . xref-find-definitions)
              ("C-c l R" . xref-find-references)
              ("C-c l h" . eldoc))
  :config
  (add-to-list 'eglot-server-programs
	       '(rust-ts-mode . ("rust-analyzer" :initializationOptions
				 (:procMacro (:enable t)
                                             :cargo (:buildScripts (:enable t)
                                                                   :features
                                                                   "all"))))
               '((js-mode typescript-mode tsx-ts-mode typescript-ts-mode js-ts-mode)
                 . ("deno" "lsp" :initializationOptions
                    (:enable t
                             :lint t
                             :unstable t
                             :config nil)))))

(provide 'paimacs-lsp)
