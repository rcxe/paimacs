(setq default-frame-alist
      (append (list
               '(vertical-scroll-bars . nil)
               '(internal-border-width . 24)
	       '(bottom-divider-width . 0)
	       '(right-divider-width . 0)
               '(undecorated-round . t)
               '(left-fringe    . 1)
               '(right-fringe   . 1)
               '(tool-bar-lines . 0)
               '(menu-bar-lines . 0))))

(tooltip-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

(setq window-divider-default-right-width 2)
(setq window-divider-default-places 'right-only)
(window-divider-mode 1)

(setq widget-image-enable nil)
(setq org-hide-emphasis-markers t)

(unless (display-graphic-p)
  (xterm-mouse-mode 1)
  (global-set-key (kbd "<mouse-4>") 'scroll-down-line)
  (global-set-key (kbd "<mouse-5>") 'scroll-up-line)
  (setq mouse-wheel-scroll-amount '(1 ((shift) . 1)))
  (setq mouse-wheel-progressive-speed nil))

(provide 'paimacs-layout)
