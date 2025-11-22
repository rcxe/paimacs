;;;###autoload
(defun paimacs-version ()
  "Return Pλimacs version string from git.
  Shows commit hash and date if installed via git, otherwise shows fallback version."
  (interactive)
  (let* ((default-directory user-emacs-directory)
	 (git? (file-directory-p (expand-file-name ".git" default-directory)))
	 (sh   (lambda (cmd) (string-trim (shell-command-to-string cmd))))
	 (version
	  (if git?
	      (let ((commit (funcall sh "git rev-parse --short HEAD"))
		    (date   (funcall sh "git log -1 --format=%cd --date=format:'%Y-%m-%d'"))
		    (branch (funcall sh "git rev-parse --abbrev-ref HEAD"))
		    (dirty  (if (string-empty-p (funcall sh "git status --porcelain"))
				"" "-dirty")))
		(format "%s@%s (%s)%s" branch commit date dirty))
	    "0.1.0 (no git)")))
    (if (called-interactively-p 'any)
	(message "Pλimacs %s" version)
      version)))


;;;###autoload
(defun paimacs-reload-settings ()
  "Reload Pλimacs settings from the disk."
  (interactive)
  (let ((user-config (expand-file-name "user.el" user-emacs-directory)))
    (when (file-exists-p user-config)
      (load user-config)
      (paimacs-apply-settings))))

;;;###autoload
(defun paimacs-open-user-config ()
  "Open user.el configuration file."
  (interactive)
  (find-file (expand-file-name "user.el" user-emacs-directory)))

;;;###autoload
(defun paimacs-apply-settings ()
  "Apply local settings to Pλimacs."
  (interactive)
  (paimacs-apply-theme)
  (paimacs-apply-indent-settings)
  (paimacs-apply-line-numbers))

;;;###autoload
(defun paimacs-info ()
  "Display Paimacs configuration and system info in a floating dialog."
  (interactive)
  (let ((buf (get-buffer-create "*Pλimacs Info*")))
    (with-current-buffer buf
      (let ((inhibit-read-only t))
	(erase-buffer)
	(insert "\n")
	(insert (propertize "Pλimacs" 
			    'face '(:height 1.5 :weight bold)))
	(insert "\n\n")
	(insert (propertize "Version: " 'face 'bold)
		(propertize (paimacs-version) 'face 'nano-face-salient) "\n")
	(insert (propertize "Emacs: " 'face 'bold)
		(propertize emacs-version 'face 'nano-face-faded) "\n\n")

	(insert (propertize "UI Settings" 'face '(nano-face-salient :weight bold)) "\n")
	(insert (propertize "  Font: " 'face 'nano-face-faded)
		(format "%s %dpt\n" paimacs-ui-font-family paimacs-ui-font-size))
	
	(insert (propertize "\nEditor Settings" 'face '(nano-face-salient :weight bold)) "\n")
	(insert (propertize "  Indent: " 'face 'nano-face-faded)
		(format "%s (%d width)\n" paimacs-editor-indent-style paimacs-editor-tab-width))
	(insert (propertize "  Line numbers: " 'face 'nano-face-faded)
		(format "%s\n" paimacs-editor-line-numbers))
	(insert (propertize "  Auto-format: " 'face 'nano-face-faded)
		(format "%s\n" paimacs-editor-auto-format))

	(when (boundp 'emacs-init-time)
	  (insert "\n" (propertize "Startup time: " 'face 'bold)
		  (propertize (format "%.2fs" (string-to-number emacs-init-time))
			      'face 'nano-face-popout) "\n"))
	
	(insert (propertize "\n[Press q to close]" 'face 'shadow))
	(goto-char (point-min))
	(setq buffer-read-only t)
	(special-mode)
	(use-local-map (make-sparse-keymap))
        (setq-local inhibit-message t)
	(local-set-key (kbd "q") 'paimacs-info-quit)
	(local-set-key (kbd "C-g") 'paimacs-info-quit)
	(local-set-key [escape] 'paimacs-info-quit)
	(setq-local no-mode-line t)
	(setq-local mode-line-format nil)
	(setq-local header-line-format nil)
	(setq-local display-line-numbers nil)
	(setq-local cursor-type nil))
      (paimacs-info--show-popup buf))))

(defun paimacs-info-quit ()
  "Close the Pλimacs info dialog."
  (interactive)
  (let ((frame (window-frame)))
    (if (frame-parameter frame 'paimacs-info-frame)
	(progn 
	  (delete-frame frame)
	  (ignore-errors (kill-buffer "*Pλimacs Info*")))
      (quit-window t))))

(defun paimacs-info--popup-frame (buffer cols lines)
  (let* ((p (selected-frame))
         (cw (frame-char-width p))
         (ch (frame-char-height p))
         (w (* cols cw))
         (h (* lines ch)))
    (make-frame
     `((parent-frame . ,p)
       (paimacs-info-frame . t)
       (width . ,cols)
       (height . ,lines)
       (left-fringe . 48)
       (right-fringe . 48)
       (left . ,(+ (frame-parameter p 'left) (/ (- (frame-pixel-width p) w) 2)))
       (top . ,(+ (frame-parameter p 'top) (/ (- (frame-pixel-height p) h) 2)))
       (undecorated . t)
       (internal-border-width . 1)))))

(defun paimacs-info--show-popup (buffer)
  (if (not (display-graphic-p))
      (select-window
       (display-buffer-in-side-window
	buffer '((side . bottom) (window-height . 0.4))))
    (let ((frame (paimacs-info--popup-frame buffer 48 18)))
      (select-frame-set-input-focus frame)
      (switch-to-buffer buffer)
      (add-hook 'delete-frame-functions
		(lambda (f)
		  (when (eq f frame)
		    (ignore-errors (kill-buffer buffer))))
		nil t))))

(provide 'paimacs-lib)
