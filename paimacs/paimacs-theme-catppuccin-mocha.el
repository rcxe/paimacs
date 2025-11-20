(defun nano-theme-set-catppuccin-mocha ()
  "Apply dark Nano theme base with Catppuccin Mocha colors."
  (setq frame-background-mode     'dark)
  (setq nano-color-foreground "#cdd6f4") ;; Text
  (setq nano-color-background "#1e1e2e") ;; Base
  (setq nano-color-highlight  "#313244") ;; Surface0
  (setq nano-color-critical   "#f38ba8") ;; Red
  (setq nano-color-salient    "#89b4fa") ;; Blue
  (setq nano-color-strong     "#cdd6f4") ;; Text
  (setq nano-color-popout     "#fab387") ;; Peach
  (setq nano-color-subtle     "#45475a") ;; Surface1
  (setq nano-color-faded      "#6c7086") ;; Overlay0
  (setq nano-theme-var "catppuccin-mocha"))

(provide 'paimacs-theme-catppuccin-mocha)
