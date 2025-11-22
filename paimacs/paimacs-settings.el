
;;; paimacs-settings.el --- User-configurable settings -*- lexical-binding: t -*-

;;; Commentary:
;; This module defines all user-configurable options for Paimacs.
;; These are easily able to be changed in your user.el file!

;;; Code:

;;;###autoload
(defmacro paimacs! (ns &rest settings)
  "Assign values to existing paimacs-* defcustom variables."
  (declare (indent 1))
  `(progn
     ,@(mapcar
        (lambda (s)
          (let* ((name (car s))
                 (value (cadr s))
                 (sym (intern (format "paimacs-%s-%s" ns name))))
            `(setq ,sym ,value)))
        settings)))

(defgroup paimacs nil
  "Customization group for Pλimacs."
  :group 'emacs
  :prefix "paimacs-")

;;; UI
(defgroup paimacs-ui nil
  "UI configuration for Pλimacs."
  :group 'paimacs)

(defcustom paimacs-ui-font-family "JetBrains Mono"
  "Default monospace font family."
  :type 'string
  :group 'paimacs-ui)

(defcustom paimacs-ui-font-size 10
  "Default font size in points."
  :type 'integer
  :group 'paimacs-ui)

;;; Editor Settings

(defgroup paimacs-editor nil
  "Editor behaviour configuration."
  :group 'paimacs)

(defcustom paimacs-editor-indent-style 'spaces
  "Indentation style to use."
  :type '(choice (const :tag "Tabs" tabs)
                 (const :tag "Spaces" spaces))
  :group 'paimacs-editor)

(defcustom paimacs-editor-tab-width 2
  "Width of tab character."
  :type 'integer
  :group 'paimacs-editor)

(defcustom paimacs-editor-line-numbers 'absolute
  "Line number display mode."
  :type '(choice (const :tag "Disabled" nil)
                 (const :tag "Absolute" absolute)
                 (const :tag "Relative" relative))
  :group 'paimacs-editor)

(defcustom paimacs-editor-auto-format t
  "Whether to format code on save."
  :type 'boolean
  :group 'paimacs-editor)

;;; Auto-updating mechanism
(defgroup paimacs-update nil
  "Auto-update settings for Pλimacs."
  :group 'paimacs)

(defcustom paimacs-update-check-on-startup t
  "Whether to check for updates on startup."
  :type 'boolean
  :group 'paimacs-update)

(defcustom paimacs-update-auto-update nil
  "Whether to automatically update without prompting.
If nil, will prompt user before updating."
  :type 'boolean
  :group 'paimacs-update)

(defcustom paimacs-update-branch "main"
  "Git branch to track for updates."
  :type 'string
  :group 'paimacs-update)

(defcustom paimacs-update-remote-url "https://github.com/rcxe/paimacs.git"
  "Git remote to fetch updates from."
  :type 'string
  :group 'paimacs-update)

(provide 'paimacs-settings)
