(use-package corfu
  :ensure t
  :custom
  (corfu-cycle t) 
  (corfu-preview-current t)
  (corfu-preselect 'prompt)
  (corfu-min-width 60)
  (corfu-max-width 30)
  (corfu-auto t)
  :hook
  (prog-mode . corfu-mode)
  :init
  (global-corfu-mode)
  (corfu-history-mode)
  (corfu-popupinfo-mode)
  :bind (:map corfu-map
              ("TAB" . corfu-next)
              ([tab] . corfu-next)
              ("S-TAB" . corfu-previous)
              ([backtab] . corfu-previous)))

(use-package cape
  :ensure t
  :bind ("C-c p" . cape-prefix-map)
  :hook
  ((completion-at-point-functions . cape-dabbrev)
   (completion-at-point-functions . cape-file)
   (completion-at-point-functions . cape-elisp-block)))

(use-package kind-icon
  :ensure t
  :after corfu
  :custom
  (kind-icon-blend-background t)
  (kind-icon-default-face 'corfu-default)
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

(use-package emacs
  :custom
  (text-mode-ispell-word-completion nil)
  (read-extended-command-predicate #'command-completion-default-include-p))

(provide 'paimacs-completion)
