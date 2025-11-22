(defvar paimacs-update--last-check-file
  (expand-file-name ".last-update-check" user-emacs-directory))
(defvar paimacs-update--checking nil)
(defvar paimacs-update--process nil)

(defun paimacs-update--git-installed-p ()
  (and (file-directory-p (expand-file-name ".git" user-emacs-directory))
     (executable-find "git")))

(defun paimacs-update--git-command (&rest args)
  (let ((default-directory user-emacs-directory))
    (condition-case err
        (let* ((lines (apply #'process-lines "git" args))
               (out (mapconcat #'identity lines "\n")))
          (string-trim out))
      (error
       (message "Pλimacs git error: %s" err)
       ""))))

(defun paimacs-update--git-operation (name sentinel &rest args)
  (let* ((default-directory user-emacs-directory)
         (proc
          (apply #'start-process name "*Messages*" "git" args)))
    (set-process-sentinel proc sentinel)
    proc))

(defun paimacs-update--has-local-changes-p ()
  (let ((default-directory user-emacs-directory))
	(not (string-empty-p
		   (string-trim
			 (shell-command-to-string "git status --porcelain"))))))

(defun paimacs-update--save-check-time ()
  (with-temp-file paimacs-update--last-check-file
    (insert (number-to-string (float-time)))))

(defun paimacs-update--get-commit-diff ()
  (let ((behind (string-to-number
                 (or (paimacs-update--git-command
                      "rev-list" "--count"
                      (format "HEAD..origin/%s"
                              paimacs-update-branch))
                     "0")))
        (ahead (string-to-number
                (or (paimacs-update--git-command
                     "rev-list" "--count"
                     (format "origin/%s..HEAD"
                             paimacs-update-branch))
                    "0"))))
    (list behind ahead)))

(defun paimacs-check-updates--sentinel (process _event)
  (setq paimacs-update--checking nil
        paimacs-update--process nil)
  (let ((status (process-status process))
        (code   (process-exit-status process)))
    (cond
     ((and (eq status 'exit) (= code 0))
      (paimacs-update--handle-check-result))
     ((eq status 'exit)
      (message "Failed to check for updates (exit %d)" code))
     (t (message "Update-check process ended unexpectedly: %s" status)))))

(defun paimacs-update--should-check-p ()
  (if (not (file-exists-p paimacs-update--last-check-file))
      t
    (let* ((last (string-to-number (with-temp-buffer
                                     (insert-file-contents paimacs-update--last-check-file)
                                     (buffer-string))))
           (now (float-time))
           (hours (/ (- now last) 3600.0)))
      (> hours 1))))

(defun paimacs-update--handle-check-result ()
  (pcase-let ((`(,behind ,ahead) (paimacs-update--get-commit-diff)))
    (cond
     ((and (zerop behind) (zerop ahead))
      (message "You're up to date!")
      (paimacs-update--save-check-time))
     ((> ahead 0)
      (message "Warning: Your local version is %d commit%s ahead of remote. Cannot auto-update."
               ahead (if (> ahead 1) "s" ""))
      (when (> behind 0)
        (message "Also %d commit%s behind. Consider manual merge." behind (if (> behind 1) "s" ""))))
     ((> behind 0)
      (if (or paimacs-update-auto-update
              (y-or-n-p (format "Update available! (%d commit%s behind). Update now? "
                                behind (if (> behind 1) "s" ""))))
          (paimacs-update)
        (message "Update available. Run M-x paimacs-update to update.")))
     (t (message "Could not determine update status")))))

;;;###autoload
(defun paimacs-check-updates ()
  "Check if updates are available for Pλimacs."
  (interactive)
  (cond
   (paimacs-update--checking
    (user-error "Update check already in progress"))
   ((not (paimacs-update--git-installed-p))
    (user-error "Pλimacs was not installed via git. Cannot check for updates"))
   (t
    (setq paimacs-update--checking t)
    (message "Checking for Pλimacs updates...")
	    (setq paimacs-update--process
          (paimacs-update--git-operation
           "paimacs-check-updates"
           #'paimacs-check-updates--sentinel
           "fetch" paimacs-update-remote-url paimacs-update-branch)))))

;;;###autoload
(defun paimacs-update ()
  "Perform an update by pulling from git."
  (interactive)
  (cond
   (paimacs-update--checking
    (user-error "Update check in progress, please wait"))
   ((not (paimacs-update--git-installed-p))
    (user-error "Pλimacs was not installed via git. Cannot update"))
   (t
    (pcase-let ((`(,behind ,ahead) (paimacs-update--get-commit-diff)))
      (when (and ahead (> ahead 0))
        (user-error "Cannot update: local is %d commit%s ahead. Manual merge required"
                    ahead (if (> ahead 1) "s" ""))))
    (when (paimacs-update--has-local-changes-p)
      (if (y-or-n-p "You have local changes. Stash them? ")
          (progn
            (message "Stashing local changes...")
            (paimacs-update--git-command "stash" "push" "-m" "Pλimacs auto-update stash"))
        (user-error "Cannot update with uncommitted changes")))
	    (setq paimacs-update--process
          (paimacs-update--git-operation
           "paimacs-update"
           #'paimacs-update--sentinel
           "pull" paimacs-update-remote-url paimacs-update-branch)))))

(defun paimacs-update--sentinel (process _event)
  (setq paimacs-update--process nil)
  (let ((status (process-status process))
        (code   (process-exit-status process)))
    (cond
     ((and (eq status 'exit) (= code 0))
      (paimacs-update--save-check-time)
      (message "Pλimacs updated successfully! Restart Emacs to apply changes.")
      (when (y-or-n-p "Restart now? ")
        (paimacs-update--restart-emacs)))
     ((eq status 'exit)
      (message "Update failed with exit code %d. See *Messages*." code))
     (t (message "Update process ended unexpectedly: %s" status)))))

(defun paimacs-update--restart-emacs ()
  (save-some-buffers)
  (let ((restart-cmd
         (if (boundp 'restart-emacs-executable)
             restart-emacs-executable
           (car command-line-args))))
    (call-process restart-cmd nil 0 nil)
    (kill-emacs)))

;;;###autoload
(defun paimacs-update-view-changelog ()
  "View commits since last update."
  (interactive)
  (unless (paimacs-update--git-installed-p)
    (user-error "Pλimacs was not installed via git"))
  (let ((log (paimacs-update--git-command
              "log" "--oneline" "--graph"
              (format "HEAD..origin/%s" paimacs-update-branch))))
    (if (string-empty-p (string-trim log))
        (message "No new commits available")
      (with-output-to-temp-buffer "*Pλimacs Changelog*"
        (princ "Pλimacs Update Changelog\n")
        (princ "=\n\n")
        (princ log)))))

;;;###autoload
(defun paimacs-update-rollback ()
  "Rollback to previous commit."
  (interactive)
  (unless (paimacs-update--git-installed-p)
    (user-error "Pλimacs was not installed via git"))
  (when (y-or-n-p "Rollback to previous commit? This will reset any local changes. ")
    (paimacs-update--git-command "reset" "--hard" "HEAD~1")
    (message "Rolled back to previous commit. Restart Emacs to apply changes.")
    (when (y-or-n-p "Restart now? ")
      (paimacs-update--restart-emacs))))

(when (bound-and-true-p paimacs-update-check-on-startup)
  (run-with-idle-timer
   5 nil
   (lambda ()
     (when (and (paimacs-update--git-installed-p)
                (paimacs-update--should-check-p))
       (paimacs-check-updates)))))

(provide 'paimacs-updater)
