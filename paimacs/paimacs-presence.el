(require 'bindat)
(require 'cl-lib)
(require 'json)
(require 'subr-x)

(defun tenor (id)
  "Return a Tenor GIF URL for ID."
  (concat "https://c.tenor.com/" id "/tenor.gif"))

(defvar paimacs-presence-client-id "1430340921655824454")

(defvar paimacs-presence-icons-url
  "https://raw.githubusercontent.com/vyfor/icons/master/icons/catppuccin/dark/")

(defvar paimacs-presence-custom-icons
  `((lua-mode . ,(tenor "KmYSTywqDXQAAAAd"))
    (lua-ts-mode . ,(tenor "KmYSTywqDXQAAAAd"))
    (rust-mode . ,(tenor "nsca48PHw3EAAAAd"))
    (rust-ts-mode . ,(tenor "nsca48PHw3EAAAAd"))
    (rustic-mode . ,(tenor "nsca48PHw3EAAAAd"))
    (css-mode . ,(tenor "HSR9RfX2sg8AAAAd"))
    (css-ts-mode . ,(tenor "HSR9RfX2sg8AAAAd"))
    (go-mode . ,(tenor "mXyOpGSME-wAAAAd"))
    (go-ts-mode . ,(tenor "mXyOpGSME-wAAAAd"))
    (emacs-lisp-mode . ,(tenor "vRhyjiVjol4AAAAC"))
    (typescript-mode . ,(tenor "vRhyjiVjol4AAAAC"))
    (typescript-ts-mode . ,(tenor "vRhyjiVjol4AAAAC"))
    (tsx-ts-mode . ,(tenor "KmYSTywqDXQAAAAC"))
    (c-mode . ,(tenor "YmV8r8fWcAEAAAAC"))
    (c-ts-mode . ,(tenor "YmV8r8fWcAEAAAAC"))
    (c++-mode . ,(tenor "NbZWkOuZRKwAAAAd"))
    (c++-ts-mode . ,(tenor "NbZWkOuZRKwAAAAd"))
    (makefile-mode . ,(tenor "mzFM-IgyzkUAAAAd"))
    (zig-mode . ,(tenor "mzFM-IgyzkUAAAAd"))
    (python-mode . ,(tenor "-Uq63LSsIXMAAAAd"))
    (python-ts-mode . ,(tenor "-Uq63LSsIXMAAAAd"))
    (nix-ts-mode . ,(tenor "NHalSD_FxNUAAAAd"))
    (sh-mode . ,(tenor "_YaK4h2W9yIAAAAd"))
    (bash-ts-mode . ,(tenor "_YaK4h2W9yIAAAAd"))
    (json-mode . "https://media.discordapp.net/stickers/1435384365017333900.gif")
    (json-ts-mode . "https://media.discordapp.net/stickers/1435384365017333900.gif")
    (yaml-mode . "https://media.discordapp.net/stickers/1435384365017333900.gif")
    (yaml-ts-mode . "https://media.discordapp.net/stickers/1435384365017333900.gif")
    (toml-mode . "https://media.discordapp.net/stickers/1435384365017333900.gif")
    (toml-ts-mode . "https://media.discordapp.net/stickers/1435384365017333900.gif")
    (conf-mode . "https://media.discordapp.net/stickers/1435384365017333900.gif")))

(defvar paimacs-presence-custom-tooltips
  '((lua-mode . "Ahoy!! We're all in the Moon♡")
    (lua-ts-mode . "Ahoy!! We're all in the Moon♡")
    (rust-mode . "rusty nature")
    (rust-ts-mode . "rusty nature")
    (rustic-mode . "rusty nature")
    (css-mode . "cascading 🎀🫐🔪")
    (css-ts-mode . "cascading 🎀🫐🔪")
    (go-mode . "gora")
    (go-ts-mode . "gora")
    (emacs-lisp-mode . "*beep*")
    (typescript-mode . "*beep*")
    (typescript-ts-mode . "*beep*")
	(nix-ts-mode . "🙂‍↔️")
    (tsx-ts-mode . "Ahoy!! We're all in the Moon♡")
    (c-mode . "💻🦋")
    (c-ts-mode . "💻🦋")
    (c++-mode . "💻🦋")
    (c++-ts-mode . "💻🦋")
    (makefile-mode . "wat 🔎")
    (zig-mode . "wat 🔎")
    (python-mode . "i despise python")
    (python-ts-mode . "i despise python")
    (sh-mode . "the blue pippa")
    (bash-ts-mode . "the blue pippa")))

(defvar paimacs-presence-mode-names
  '((c-mode . "C")
    (c-ts-mode . "C")
    (c++-mode . "C++")
    (c++-ts-mode . "C++")
    (rustic-mode . "Rust")
    (sh-mode . "Shell")
    (bash-ts-mode . "Bash")
    (tsx-ts-mode . "TSX")))

(defvar paimacs-presence-refresh-rate 5)
(defvar paimacs-presence-idle-timer 300)
(defvar paimacs-presence-idle-message "AFK...")
(defvar paimacs-presence-quiet 'nil)

(defvar paimacs-presence--startup-time (string-to-number (format-time-string "%s" (current-time))))
(defvar paimacs-presence-boring-buffers-regexp-list '("^ " "\\\\*Messages\\\\*"))

;;;###autoload
(define-minor-mode paimacs-presence-mode
  "Global minor mode for displaying Rich Presence in Discord."
  nil nil nil
  :require 'paimacs-presence
  :global t
  :group 'paimacs
  :after-hook
  (if paimacs-presence-mode
      (paimacs-presence--enable)
    (paimacs-presence--disable)))

(defvar paimacs-presence--editor-name "Paimacs")
(defvar paimacs-presence--discord-ipc-pipe- "discord-ipc-%d")
(defvar paimacs-presence--update-presence-timer nil)
(defvar paimacs-presence--reconnect-timer nil)
(defvar paimacs-presence--sock nil)
(defvar paimacs-presence--last-known-position (count-lines (point-min) (point)))
(defvar paimacs-presence--last-known-buffer-name (buffer-name))
(defvar paimacs-presence--idle-status nil)

(defun paimacs-presence--find-discord-ipc-pipe ()
  (let ((candidates
         (mapcan
          (lambda (dir)
            (mapcar
             (lambda (num)
               (expand-file-name (format "discord-ipc-%d" num) dir))
             (number-sequence 0 9)))
          (list (expand-file-name "app/com.discordapp.Discord"
                                  (getenv "XDG_RUNTIME_DIR"))
                (getenv "XDG_RUNTIME_DIR")
                (getenv "TMPDIR")
                (getenv "TMP")
                (getenv "TEMP")
                "/tmp"))))
    (cl-loop for candidate in candidates
             until (file-exists-p candidate)
             finally return candidate)))

(defun paimacs-presence--make-process ()
  "Make the asynchronous process that communicates with Discord IPC."
  (make-network-process
   :name "*paimacs-presence-sock*"
   :remote (paimacs-presence--find-discord-ipc-pipe)
   :service nil
   :sentinel 'paimacs-presence--connection-sentinel
   :filter 'paimacs-presence--connection-filter
   :noquery t))

(defun paimacs-presence--enable ()
  "Called when variable ‘paimacs-presence-mode’ is enabled."
  (setq paimacs-presence--startup-time (string-to-number (format-time-string "%s" (current-time))))
  (unless (paimacs-presence--resolve-client-id)
    (warn "paimacs-presence: no paimacs-presence-client-id available"))
  (when paimacs-presence-idle-timer
    (run-with-idle-timer
     paimacs-presence-idle-timer t 'paimacs-presence--start-idle))
  (paimacs-presence--start-reconnect))

(defun paimacs-presence--disable ()
  "Called when variable ‘paimacs-presence-mode’ is disabled."
  (paimacs-presence--cancel-updates)
  (paimacs-presence--cancel-reconnect)
  (when paimacs-presence--sock
    (paimacs-presence--empty-presence))
  (cancel-function-timers 'paimacs-presence--start-idle)
  (paimacs-presence--disconnect))

(defun paimacs-presence--empty-presence ()
  "Sends an empty presence for when paimacs-presence is disabled."
  (let* ((nonce (format-time-string "%s%N"))
         (presence
          `(("cmd" . "SET_ACTIVITY")
            ("args" . (("activity" . nil)
                       ("pid" . ,(emacs-pid))))
            ("nonce" . ,nonce))))
    (paimacs-presence--send-packet 1 presence)))

(defun paimacs-presence--resolve-client-id ()
  "Evaluate `paimacs-presence-client-id' and return the client ID to use."
  (cl-typecase paimacs-presence-client-id
    (null
     nil)
    (string
     paimacs-presence-client-id)
    (function
     (funcall paimacs-presence-client-id))))

(defun paimacs-presence--slugify (s)
  (let ((s (downcase s)))
    (replace-regexp-in-string "[^a-z0-9]+" "" s)))

(defun paimacs-presence--get-icon-url (icon-name)
  (concat paimacs-presence-icons-url icon-name ".png"))

(defun paimacs-presence--canonical-name ()
  (or (cdr (assq major-mode paimacs-presence-mode-names))
      (cond
       ((stringp mode-name) mode-name)
       ((and (listp mode-name) (stringp (car mode-name))) (car mode-name))
       (t (format "%s" mode-name)))))

(defun paimacs-presence--mode-icon ()
  (or (cdr (assq major-mode paimacs-presence-custom-icons))
      (when (eq major-mode 'emacs-lisp-mode)
        (paimacs-presence--get-icon-url "lisp"))
      (paimacs-presence--get-icon-url
       (paimacs-presence--slugify
        (paimacs-presence--canonical-name)))))

(defun paimacs-presence--mode-text ()
  (or (cdr (assq major-mode paimacs-presence-custom-tooltips))
      (paimacs-presence--canonical-name)))

(defun paimacs-presence--connection-sentinel (process evnt)
  "Track connection state change on Discord connection.
Argument PROCESS The process this sentinel is attached to.
Argument EVNT The event which triggered the sentinel to run."
  (cl-case (process-status process)
    ((closed exit)
     (paimacs-presence--handle-disconnect))
    (t)))

(defun paimacs-presence--connection-filter (process evnt)
  "Track incoming data from Discord connection.
Argument PROCESS The process this filter is attached to.
Argument EVNT The available output from the process."
  (paimacs-presence--start-updates))

(defun paimacs-presence--connect ()
  "Connects to the Discord socket."
  (or paimacs-presence--sock
      (condition-case err
          (progn
            (unless paimacs-presence-quiet
              (message "paimacs-presence: attempting reconnect.."))
            (setq paimacs-presence--sock (paimacs-presence--make-process))
            (paimacs-presence--send-packet 0
                                           `(("v" . 1)
                                             ("client_id" . ,(paimacs-presence--resolve-client-id))))
            paimacs-presence--sock)
        (error
         (message "paimacs-presence: failed to connect: %S" err)
         (setq paimacs-presence--sock nil)))))

(defun paimacs-presence--disconnect ()
  "Disconnect paimacs-presence."
  (when paimacs-presence--sock
    (delete-process paimacs-presence--sock)
    (setq paimacs-presence--sock nil)))

(defun paimacs-presence--reconnect ()
  "Attempt to reconnect paimacs-presence."
  (when (paimacs-presence--connect)
    (unless (or paimacs-presence--update-presence-timer paimacs-presence-quiet)
      (message "paimacs-presence: connecting..."))
    (paimacs-presence--cancel-reconnect)))

(defun paimacs-presence--start-reconnect ()
  "Start attempting to reconnect."
  (unless (or paimacs-presence--sock paimacs-presence--reconnect-timer)
    (setq paimacs-presence--reconnect-timer (run-at-time 0 15 'paimacs-presence--reconnect))))

(defun paimacs-presence--cancel-reconnect ()
  "Cancels any ongoing reconnection attempt."
  (when paimacs-presence--reconnect-timer
    (cancel-timer paimacs-presence--reconnect-timer)
    (setq paimacs-presence--reconnect-timer nil)))

(defun paimacs-presence--handle-disconnect ()
  "Handles reconnecting when socket disconnects."
  (unless paimacs-presence-quiet
    (message "paimacs-presence: disconnected by remote host"))
  (paimacs-presence--cancel-updates)
  (setq paimacs-presence--sock nil)
  (when paimacs-presence-mode
    (paimacs-presence--start-reconnect)))

(defun paimacs-presence--send-packet (opcode obj)
  (let* ((jsonstr
          (encode-coding-string
           (json-encode obj)
           'utf-8))
         (datalen (length jsonstr))
         (message-spec
          `((:op u32r)
            (:len u32r)
            (:data str ,datalen)))
         (packet
          (bindat-pack
           message-spec
           `((:op . ,opcode)
             (:len . ,datalen)
             (:data . ,jsonstr)))))
                                        ; (message "paimacs-presence: sending JSON packet op=%d: %s" opcode jsonstr)
    (when paimacs-presence--sock
      (process-send-string paimacs-presence--sock packet))))

(defun paimacs-presence--mode-icon-and-text ()
  (let* ((text (paimacs-presence--mode-text))
         (icon (paimacs-presence--mode-icon))
         (large-text text)
         (large-image icon)
         (small-text paimacs-presence--editor-name))
    `(("large_text" . ,large-text)
      ("large_image" . ,large-image))))

(defun paimacs-presence-buffer-details-format ()
  (format "Editing %s" (buffer-name)))

(defun paimacs-presence--details-and-state ()
  (let* ((dir-name (file-name-nondirectory
                    (directory-file-name default-directory)))
         (activity `(("details" . ,(paimacs-presence-buffer-details-format))
                     ("state" . ,(format "in %s" dir-name)))))
    (push (list "timestamps" (cons "start" paimacs-presence--startup-time)) activity)
    activity))

(defun paimacs-presence--set-presence ()
  (let* ((activity
          `(("assets" . (,@(paimacs-presence--mode-icon-and-text)))
            ,@(paimacs-presence--details-and-state)))
         (nonce (format-time-string "%s%N"))
         (presence
          `(("cmd" . "SET_ACTIVITY")
            ("args" . (("activity" . ,activity)
                       ("pid" . ,(emacs-pid))))
            ("nonce" . ,nonce))))
    (paimacs-presence--send-packet 1 presence)))

(defun paimacs-presence--buffer-boring-p (buffer-name)
  (cl-some (lambda (re) (string-match-p re buffer-name))
           paimacs-presence-boring-buffers-regexp-list))

(defun paimacs-presence--find-non-boring-window ()
  (cl-find-if (lambda (window)
                (not (paimacs-presence--buffer-boring-p
                      (buffer-name (window-buffer window)))))
              (window-list)))

(defun paimacs-presence--try-update-presence (new-buffer-name new-buffer-position)
  (setq paimacs-presence--last-known-buffer-name new-buffer-name
        paimacs-presence--last-known-position new-buffer-position)
  (condition-case err
      (paimacs-presence--set-presence)
    (error
     (message "paimacs-presence: error setting presence: %s" (error-message-string err))
     (paimacs-presence--cancel-updates)
     (paimacs-presence--disconnect)
     (paimacs-presence--start-reconnect))))

(defun paimacs-presence--update-presence ()
  "Conditionally update presence by testing the current buffer/line.
If there is no 'previous' buffer attempt to find a non-boring buffer to initialize to."
  (if (= paimacs-presence--last-known-position -1)
      (when-let ((window (paimacs-presence--find-non-boring-window)))
        (with-current-buffer (window-buffer window)
          (paimacs-presence--try-update-presence (buffer-name) (count-lines (point-min) (point)))))
    (let ((new-buffer-name (buffer-name (current-buffer))))
      (unless (paimacs-presence--buffer-boring-p new-buffer-name)
        (let ((new-buffer-position (count-lines (point-min) (point))))
          (unless (and (string= new-buffer-name paimacs-presence--last-known-buffer-name)
                       (= new-buffer-position paimacs-presence--last-known-position))
            (paimacs-presence--try-update-presence new-buffer-name new-buffer-position)))))))

(defun paimacs-presence--start-updates ()
  "Start sending periodic update to Discord Rich Presence."
  (unless paimacs-presence--update-presence-timer
    (unless paimacs-presence-quiet
      (message "paimacs-presence: connected. starting updates"))
    ;;Start sending updates now that we've heard from discord
    (setq paimacs-presence--last-known-position -1
          paimacs-presence--last-known-buffer-name ""
          paimacs-presence--update-presence-timer (run-at-time 0 paimacs-presence-refresh-rate 'paimacs-presence--update-presence))))

(defun paimacs-presence--cancel-updates ()
  "Stop sending periodic update to Discord Rich Presence."
  (when paimacs-presence--update-presence-timer
    (cancel-timer paimacs-presence--update-presence-timer)
    (setq paimacs-presence--update-presence-timer nil)))

(defun paimacs-presence--start-idle ()
  "Set presence to idle, pause update and timer."
  (unless paimacs-presence--idle-status
    (unless paimacs-presence-quiet
      (message (format "paimacs-presence: %s" paimacs-presence-idle-message)))

    ;;hacky way to stop updates and store elapsed time
    (cancel-timer paimacs-presence--update-presence-timer)
    (setq paimacs-presence--startup-time (string-to-number (format-time-string "%s" (time-subtract nil paimacs-presence--startup-time)))

          paimacs-presence--idle-status t)

    (let* ((activity
            `(("assets" . (,@(paimacs-presence--mode-icon-and-text)))
              ("timestamps" ("start" ,@(string-to-number (format-time-string "%s" (current-time)))))
              ("details" . "Idle") ("state" .  ,paimacs-presence-idle-message)))
           (nonce (format-time-string "%s%N"))
           (presence
            `(("cmd" . "SET_ACTIVITY")
              ("args" . (("activity" . ,activity)
                         ("pid" . ,(emacs-pid))))
              ("nonce" . ,nonce))))
      (paimacs-presence--send-packet 1 presence))
    (add-hook 'pre-command-hook 'paimacs-presence--cancel-idle)))

(defun paimacs-presence--cancel-idle ()
  (when paimacs-presence--idle-status
    (remove-hook 'pre-command-hook 'paimacs-presence--cancel-idle)
    (setq paimacs-presence--startup-time (string-to-number (format-time-string "%s" (time-subtract nil paimacs-presence--startup-time)))
          paimacs-presence--idle-status nil
          paimacs-presence--update-presence-timer nil)
    (paimacs-presence--start-updates)
    (unless paimacs-presence-quiet
      (message "paimacs-presence: welcome back"))))

(paimacs-presence-mode)
(provide 'paimacs-presence)
