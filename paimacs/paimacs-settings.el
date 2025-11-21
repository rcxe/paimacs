
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

;;;###autoload
(defun paimacs-reload-settings ()
  (interactive)
  (let ((user-config (expand-file-name "user.el" user-emacs-directory)))
    (when (file-exists-p user-config)
      (load user-config)
      (paimacs-apply-settings))))

;;;###autoload
(defun paimacs-find-user-settings ()
  (interactive)
  (find-file (expand-file-name "user.el" user-emacs-directory)))

(defgroup paimacs nil
  "Customization group for Paimacs."
  :group 'emacs
  :prefix "paimacs-")

;;; UI
(defgroup paimacs-ui nil
  "UI configuration for Paimacs."
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

(provide 'paimacs-settings)
