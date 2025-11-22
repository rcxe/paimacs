;;; paimacs --- Newbie-friendly Emacs distribution -*- lexical-binding: t -*-

;; Copyright (C) 2025 rcxe

;; Package-Requires: ((emacs "29.1"))
;; Keywords: convenience
;; URL: https://github.com/rcxe/paimacs

;;; Commentary:

;; Paimacs is a newbie-friendly Emacs distribution built on top of
;; N Λ N O Emacs, providing sensible defaults and modern tooling.

;;; Code:

(when (and (boundp 'load-path) load-file-name)
  (add-to-list 'load-path
             (expand-file-name "paimacs" user-emacs-directory))
    (add-to-list 'load-path
             (expand-file-name "nano" user-emacs-directory)))

(require 'paimacs-settings)
(require 'paimacs-lib)
(require 'paimacs-package-manager)
(require 'paimacs-nano)
(require 'paimacs-layout)
(require 'paimacs-sane)
(require 'paimacs-buffer)
(require 'paimacs-appearance)
(require 'paimacs-modeline)
(require 'paimacs-lsp)
(require 'paimacs-completion)
(require 'paimacs-vertico)
(require 'paimacs-indent)
(require 'paimacs-normie)
(require 'paimacs-dashboard)
(require 'paimacs-diagnostics)
(require 'paimacs-treesitter)
(require 'paimacs-help)
(require 'paimacs-git)
(require 'paimacs-files)
(require 'paimacs-bindings)
(require 'paimacs-presence)
(require 'paimacs-formatter)
(require 'paimacs-branding)
(require 'paimacs-utilities)
(require 'paimacs-web)

(add-hook 'emacs-startup-hook
          (lambda () (paimacs-reload-settings)))
