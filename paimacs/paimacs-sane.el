;; sane defaults

(setq warning-minimum-level :error
      debug-on-error nil)

(setq inhibit-startup-screen t
      inhibit-startup-message t
      inhibit-startup-echo-area-message t
      initial-scratch-message nil
      initial-buffer-choice nil
      cursor-in-non-selected-windows nil
      ring-bell-function 'ignore
      use-short-answers t
      confirm-kill-emacs 'yes-or-no-p)

(setq initial-major-mode 'text-mode
      default-major-mode 'text-mode)

(setq confirm-nonexistent-file-or-buffer nil
      org-return-follows-link t)
(fset 'yes-or-no-p 'y-or-n-p)

(setq backup-directory-alist '((expand-file-name "backups" user-emacs-directory)))

(provide 'paimacs-sane)
