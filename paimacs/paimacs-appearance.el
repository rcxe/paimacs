(setq init-start-time (current-time))

(setq nano-font-family-monospaced "Iosevka Custom")
(setq nano-font-size 16)

(set-display-table-slot standard-display-table 'truncation (make-glyph-code ?…))
(set-display-table-slot standard-display-table 'wrap (make-glyph-code ?–))

(require 'paimacs-theme-catppuccin-mocha)
(nano-theme-set-catppuccin-mocha)
(nano-refresh-theme)

(provide 'paimacs-appearance)
