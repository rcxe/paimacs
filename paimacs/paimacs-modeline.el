;; -*- lexical-binding: t -*-

(require 'subr-x)
(use-package nerd-icons
  :ensure t)

(defun vc-branch ()
  (if vc-mode
      (let ((backend (vc-backend buffer-file-name)))
        (concat "#" (substring-no-properties vc-mode
                                             (+ (if (eq backend 'Hg) 2 3) 2))))  nil))

(defun paimacs-mode-name ()
  (if (listp mode-name) (car mode-name) mode-name))

(defun shorten-directory (dir max-length)
  "Show up to `max-length' characters of a directory name `dir'."
  (let ((path (reverse (split-string (abbreviate-file-name dir) "/")))
        (output ""))
    (when (and path (equal "" (car path)))
      (setq path (cdr path)))
    (while (and path (< (length output) (- max-length 4)))
      (setq output (concat (car path) "/" output))
      (setq path (cdr path)))
    (when path
      (setq output (concat "…/" output)))
    output))

;; -------------------------------------------------------------------
(defun paimacs-modeline-compose (status name primary secondary)
  "Compose a string with provided information"
  (let* ((char-width    (window-font-width nil 'header-line))
         (window        (get-buffer-window (current-buffer)))
         (space-up       +0.15)
         (space-down     -0.20)
         (prefix (cond ((string= status "RO")
                        (propertize (if (window-dedicated-p)" -- " " RO ")
                                    'face 'nano-face-header-popout))
                       ((string= status "**")
                        (propertize (if (window-dedicated-p)" -- " " ** ")
                                    'face 'nano-face-header-critical))
                       ((string= status "RW")
                        (propertize (if (window-dedicated-p)" -- " " RW ")
                                    'face 'nano-face-header-faded))
                       (t (propertize status 'face 'nano-face-header-popout))))
         (left (concat
                (propertize " "  'face 'nano-face-header-default
                            'display `(raise ,space-up))
                (propertize name 'face 'nano-face-header-strong)
                (propertize " "  'face 'nano-face-header-default
                            'display `(raise ,space-down))
                (propertize primary 'face 'nano-face-header-default)))
         (right (concat secondary " "))
         (available-width (- (window-total-width) 
                             (length prefix) (length left) (length right)
                             (/ (window-right-divider-width) char-width)))
         (available-width (max 1 available-width)))
    (concat prefix
            left
            (propertize (make-string available-width ?\ )
                        'face 'nano-face-header-default)
            (propertize right 'face `(:inherit nano-face-header-default
                                               :foreground ,nano-color-faded)))))

;; ---------------------------------------------------------------------
(setq Info-use-header-line nil)
(defun paimacs-modeline-info-breadcrumbs ()
  (let ((nodes (Info-toc-nodes Info-current-file))
        (cnode Info-current-node)
        (node Info-current-node)
        (crumbs ())
        (depth Info-breadcrumbs-depth)
        line)
    (while  (> depth 0)
      (setq node (nth 1 (assoc node nodes)))
      (if node (push node crumbs))
      (setq depth (1- depth)))
    (setq crumbs (cons "Top" (if (member (pop crumbs) '(nil "Top"))
                                 crumbs (cons nil crumbs))))
    (forward-line 1)
    (dolist (node crumbs)
      (let ((text
             (if (not (equal node "Top")) node
               (format "%s"
                       (if (stringp Info-current-file)
                           (file-name-sans-extension
                            (file-name-nondirectory Info-current-file))
                         Info-current-file)))))
        (setq line (concat line (if (null line) "" " > ")
                           (if (null node) "..." text)))))
    (if (and cnode (not (equal cnode "Top")))
        (setq line (concat line (if (null line) "" " > ") cnode)))
    line))

(defun paimacs-modeline-info-mode-p ()
  (derived-mode-p 'Info-mode))

(defun paimacs-modeline-info-mode ()
  (paimacs-modeline-compose (paimacs-modeline-status)
                            "Info"
                            (concat "("
                                    (paimacs-modeline-info-breadcrumbs)
                                    ")")
                            ""))

;; ---------------------------------------------------------------------
(defun paimacs-modeline-term-mode-p ()
  (derived-mode-p 'term-mode))

(defun paimacs-modeline-vterm-mode-p ()
  (derived-mode-p 'vterm-mode))

(defun paimacs-modeline-term-mode ()
  (paimacs-modeline-compose " >_ "
                            "Terminal"
                            (concat "(" shell-file-name ")")
                            (shorten-directory default-directory 32)))


;; ---------------------------------------------------------------------
(defun paimacs-modeline-nano-help-mode-p ()
  (derived-mode-p 'nano-help-mode))

(defun paimacs-modeline-nano-help-mode ()
  (paimacs-modeline-compose (paimacs-modeline-status)
                            "P Λ I M A C S"
                            "(help)"
                            ""))

;; ---------------------------------------------------------------------
(defun paimacs-modeline-docview-mode-p ()
  (derived-mode-p 'doc-view-mode))

(defun paimacs-modeline-docview-mode ()
  (let ((buffer-name (format-mode-line "%b"))
        (mode-name   (paimacs-mode-name))
        (branch      (vc-branch))
        (page-number (concat
                      (number-to-string (doc-view-current-page)) "/"
                      (or (ignore-errors
                            (number-to-string (doc-view-last-page-number)))
                          "???"))))
    (paimacs-modeline-compose
     (paimacs-modeline-status)
     buffer-name
     (concat "(" mode-name
             (if branch (concat ", "
                                (propertize branch 'face 'italic)))
             ")" )
     page-number)))

;; ---------------------------------------------------------------------
(defun paimacs-modeline-pdf-view-mode-p ()
  (derived-mode-p 'pdf-view-mode))

(defun paimacs-modeline-pdf-view-mode ()
  (let ((buffer-name (format-mode-line "%b"))
        (mode-name   (paimacs-mode-name))
        (branch      (vc-branch))
        (page-number (concat
                      (number-to-string (pdf-view-current-page)) "/"
                      (or (ignore-errors
                            (number-to-string (pdf-cache-number-of-pages)))
                          "???"))))
    (paimacs-modeline-compose
     "RW"
     buffer-name
     (concat "(" mode-name
             (if branch (concat ", "
                                (propertize branch 'face 'italic)))
             ")" )
     page-number)))

;; ---------------------------------------------------------------------
(defun buffer-menu-mode-header-line ()
  (face-remap-add-relative
   'header-line `(:background ,(face-background 'nano-face-subtle))))
(add-hook 'Buffer-menu-mode-hook
          #'buffer-menu-mode-header-line)

;; ---------------------------------------------------------------------
(defun paimacs-modeline-completion-list-mode-p ()
  (derived-mode-p 'completion-list-mode))

(defun paimacs-modeline-completion-list-mode ()
  (let ((buffer-name (format-mode-line "%b"))
        (mode-name   (paimacs-mode-name))
        (position    (format-mode-line "%l:%c")))

    (paimacs-modeline-compose (paimacs-modeline-status)
                              buffer-name "" position)))
;; ---------------------------------------------------------------------
(with-eval-after-load 'deft
  (defun deft-print-header ()
    (force-mode-line-update)
    (widget-insert "\n")))

(defun paimacs-modeline-deft-mode-p ()
  (derived-mode-p 'deft-mode))

(defun paimacs-modeline-deft-mode ()
  (let ((prefix " DEFT ")
        (primary "Notes")
        (filter  (if deft-filter-regexp
                     (deft-whole-filter-regexp) "<filter>"))
        (matches (if deft-filter-regexp
                     (format "%d matches" (length deft-current-files))
                   (format "%d notes" (length deft-all-files)))))
    (paimacs-modeline-compose " DEFT "
                              primary filter matches)))


;; ---
(defun paimacs-modeline-project-name ()
  "Return the current project name, if any."
  (when-let ((project (project-current)))
    (file-name-nondirectory
     (directory-file-name
      (project-root project)))))

(defun paimacs-modeline-file-icon ()
  "Return nerd-icon for current buffer."
  (when buffer-file-name
    (concat (nerd-icons-icon-for-file buffer-file-name) " ")))

(defun paimacs-modeline-flymake-status ()
  "Return a string with Flymake diagnostics count."
  (when (bound-and-true-p flymake-mode)
    (let ((err 0) (warn 0) (note 0))
      ;; Count diagnostics from all backends
      (dolist (diag (flymake-diagnostics))
        (pcase (flymake-diagnostic-type diag)
          (:error (cl-incf err))
          (:warning (cl-incf warn))
          (:note (cl-incf note))))
      ;; Only show if there are any diagnostics
      (when (> (+ err warn note) 0)
        (let ((status ""))
          (when (> err 0)
            (setq status (concat status 
                                 (propertize (format " E:%d" err)
                                             'face 'error))))
          (when (> warn 0)
            (setq status (concat status 
                                 (propertize (format " W:%d" warn)
                                             'face 'warning))))
          (when (> note 0)
            (setq status (concat status 
                                 (propertize (format " N:%d" note)
                                             'face 'success))))
          status)))))

;; ---------------------------------------------------------------------
(defun paimacs-modeline-prog-mode-p ()
  (derived-mode-p 'prog-mode))

(defun paimacs-modeline-text-mode-p ()
  (derived-mode-p 'text-mode))

(defun paimacs-modeline-default-mode ()
  (let* ((buffer-name (format-mode-line "%b"))
         (mode-name   (paimacs-mode-name))
         (branch      (vc-branch))
         (icon        (paimacs-modeline-file-icon))
         (project     (paimacs-modeline-project-name))
         (position    (format-mode-line "%l:%c")))
    (paimacs-modeline-compose 
     (paimacs-modeline-status)
     (concat icon buffer-name)
     (concat "(" mode-name
             (if branch (concat ", "
                                (propertize branch 'face 'italic)))
             ")" )
     (concat (if project (concat "[" project "] ") "")
             position))))

;; ---------------------------------------------------------------------
(defun paimacs-modeline-status ()
  "Return buffer status: read-only (RO), modified (**) or read-write (RW)"
  
  (let ((read-only   buffer-read-only)
        (modified    (and buffer-file-name (buffer-modified-p))))
    (cond (modified  "**") (read-only "RO") (t "RW"))))

;; ---------------------------------------------------------------------
(defun paimacs-modeline ()
  "Install a header line whose content is dependend on the major mode"
  (interactive)
  (setq-default header-line-format
                '((:eval
                   (cond ((paimacs-modeline-prog-mode-p)            (paimacs-modeline-default-mode))
                         ((paimacs-modeline-info-mode-p)            (paimacs-modeline-info-mode))
                         ((paimacs-modeline-term-mode-p)            (paimacs-modeline-term-mode))
                         ((paimacs-modeline-vterm-mode-p)           (paimacs-modeline-term-mode))
                         ((paimacs-modeline-text-mode-p)            (paimacs-modeline-default-mode))
                         ((paimacs-modeline-pdf-view-mode-p)        (paimacs-modeline-pdf-view-mode))
                         ((paimacs-modeline-docview-mode-p)         (paimacs-modeline-docview-mode))
                         ((paimacs-modeline-completion-list-mode-p) (paimacs-modeline-completion-list-mode))
                         ((paimacs-modeline-nano-help-mode-p)       (paimacs-modeline-nano-help-mode))
                         (t                                      (paimacs-modeline-default-mode)))))))

;; ---------------------------------------------------------------------
(defun paimacs-modeline-update-windows ()
  "Modify the mode line depending on the presence of a window
below or a buffer local variable 'no-mode-line'."
  (dolist (window (window-list))
    (with-selected-window window
      (with-current-buffer (window-buffer window)
        (if (or (not (boundp 'no-mode-line)) (not no-mode-line))
            (set-window-parameter window 'mode-line-format
                                  (cond ((not mode-line-format) 'none)
                                        ((one-window-p t 'visible) (list ""))
                                        ((eq (window-in-direction 'below) (minibuffer-window)) (list ""))
                                        ((not (window-in-direction 'below)) (list ""))
                                        (t 'none))))))))

(add-hook 'window-configuration-change-hook 'paimacs-modeline-update-windows)

(setq eshell-status-in-modeline nil)
;; (setq-default mode-line-format (list "%-"))
(setq-default mode-line-format "")
(paimacs-modeline)

(provide 'paimacs-modeline)
