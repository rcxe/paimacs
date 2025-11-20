(use-package which-key
  :ensure t
  :custom
  (which-key-idle-delay 0.3)
  (which-key-popup-type 'side-window)
  (which-key-side-window-location 'bottom)
  (which-key-side-window-max-height 0.1)
  (which-key-max-description-length 32)
  (which-key-add-column-padding 1)
  (which-key-sort-order 'which-key-key-order-alpha)
  (which-key-separator " → ")
  (which-key-prefix-prefix "+")
  (which-key-allow-imprecise-window-fit nil)
  :config (which-key-mode +1))

(use-package
  embark
  :ensure t
  :bind
  (("C-." . embark-act)
   ("C-;" . embark-dwim)
   ("C-h C-z" . embark-bindings))
  :config (setq prefix-help-command #'embark-prefix-help-command))

(setq mac-pass-command-to-system nil)
(global-set-key (kbd "M-p") 'paimacs-quick-help)
(defun paimacs-quick-help ()
  (interactive)
  (let ((message-log-max nil))
    (message
     (concat
      (propertize "\n" 'face '(:height 0.4))
      " [C-x C-f] Open  [C-x C-s] Save  [C-s] Search  [M-x] Command   "
      (propertize "[C-g]   Cancel" 'face 'bold)
      "\n"
      " M-g: Line/Error/Mark/Outline   M-s: Grep/Ripgrep/Line/Focus   "
      (propertize "[C-x C-c] Quit" 'face 'bold)
      (propertize "\n " 'face '(:height 0.5))))
    (sit-for 30)))

(defun paimacs-splash-help-message ()
  (message
   (concat
    (if (display-graphic-p) (propertize "\n " 'face '(:height 0.4)))
    (propertize (concat
                 "Type M-p for quick help, M-h for help."
                 " M stands for Alt, Command or (Esc)ape.")
                'face 'nano-face-faded)
    (if (display-graphic-p) (propertize "\n " 'face '(:height 0.5))))))

(defun display-startup-echo-area-message ()
  (paimacs-splash-help-message))

(provide 'paimacs-help)
