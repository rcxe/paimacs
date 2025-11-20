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
  (let ((error-color   "#f38ba8")
	(warning-color "#fab387")
	(success-color "#a6e3a1")
	(echo-fg       nano-color-faded))
    (dolist (spec `((flymake-error :underline (:color ,error-color) :background nil)
		    (flymake-error-echo :foreground ,echo-fg :background nil)
		    (sideline-flymake-error :foreground ,error-color :background nil)
		    (flymake-warning :underline (:color ,warning-color) :background nil)
		    (flymake-warning-echo :foreground ,echo-fg :background nil)
		    (sideline-flymake-warning :foreground ,warning-color :background nil)
		    (flymake-success :underline (:color ,success-color) :background nil)
		    (flymake-success-echo :foreground ,echo-fg :background nil)
		    (sideline-flymake-success :foreground ,success-color :background nil)))
      (custom-set-faces `(,(car spec) ((t ,(cdr spec)))))))
  (setq nano-theme-var "catppuccin-mocha"))

(provide 'paimacs-theme-catppuccin-mocha)
