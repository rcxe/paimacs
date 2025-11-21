(when (display-graphic-p)
  (setq frame-title-format
        '(:eval (format "%s on Paimacs" (buffer-name))))
  (let ((icon-path (expand-file-name "brand.png" user-emacs-directory)))
    (when (file-exists-p icon-path)
      (let ((img (create-image icon-path 'png nil :ascent 'center)))
        (set-frame-parameter nil 'icon-type img)))))

(provide 'paimacs-branding)
