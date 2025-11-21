(paimacs! ui
  (font-family "Iosevka Custom")
  (font-size 18))

(paimacs! editor
	(indent-style 'tabs)
	(tab-width 4)
	(line-numbers 'relative)
	(auto-format t))

(theme! catppuccin-mocha
  (frame-background-mode 'dark)
  (foreground "#cdd6f4")
  (background "#1e1e2e")
  (highlight  "#313244")
  (critical   "#f38ba8")
  (salient    "#89b4fa")
  (strong     "#cdd6f4")
  (popout     "#fab387")
  (subtle     "#45475a")
  (faded      "#6c7086"))

(presence! 'nix (tenor "NHalSD_FxNUAAAAd") "🙂‍↔️🙂‍↔️")
(fmt! nix (alejandra))

(theme-catppuccin-mocha)
