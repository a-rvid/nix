;;; init.el --- Emacs configuration -*- lexical-binding: t; -*-

(menu-bar-mode -1)
(tool-bar-mode -1)
(setq select-enable-keyboard 1)

(add-to-list 'custom-theme-load-path
             (file-name-directory (locate-library "nord-theme")))

(defun my/apply-theme (theme-name)
  (dolist (theme custom-enabled-themes)
    (disable-theme theme))
  (condition-case nil
      (load-theme (intern theme-name) t)
    (error
     (message "Unknown Emacs theme: %s" theme-name))))

(defun my/load-theme-from-state ()
  (let* ((state-dir (or (getenv "XDG_STATE_HOME")
                       (expand-file-name ".local/state" (getenv "HOME"))))
         (theme-file (expand-file-name "theme/current-theme" state-dir))
         (theme-name (if (file-exists-p theme-file)
                         (string-trim (with-temp-buffer
                                        (insert-file-contents theme-file)
                                        (buffer-string)))
                       "nord")))
    (my/apply-theme theme-name)))

(defun my/load-theme-on-frame (frame)
  (with-selected-frame frame
    (my/load-theme-from-state)))

(if (daemonp)
    (add-hook 'after-make-frame-functions #'my/load-theme-on-frame)
  (my/load-theme-from-state))

(setq backup-directory-alist
      `(("." . ,(expand-file-name "backups/" user-emacs-directory)))
      auto-save-file-name-transforms
      `((".*" ,(expand-file-name "auto-save/" user-emacs-directory) t))
      indent-tabs-mode nil)

(electric-indent-mode 1)
(when (display-graphic-p)
  (toggle-scroll-bar -1))

(use-package undo-fu
  :ensure nil
  :config
  (global-set-key (kbd "C-z") #'undo-fu-only-undo)
  (global-set-key (kbd "C-S-z") #'undo-fu-only-redo))

(use-package undo-fu-session
  :ensure nil
  :config
  (global-undo-fu-session-mode))

(use-package evil
  :ensure nil
  :init
  (setq evil-undo-system 'undo-fu)
  :config
  (evil-mode 1))

(use-package evil-commentary
  :ensure nil
  :after evil
  :config
  (evil-commentary-mode))

(use-package rustic
  :ensure nil
  :config
  (setq rustic-format-on-save nil
        rustic-cargo-use-last-stored-arguments t))

(global-set-key
 (kbd "C-c r")
 (lambda ()
   (interactive)
   (load-file user-init-file)))

(use-package vertico
  :ensure nil
  :config
  (vertico-mode))

(use-package vertico-posframe
  :ensure nil
  :after vertico
  :if (display-graphic-p)
  :config
  (vertico-posframe-mode 1)
  (setq vertico-posframe-poshandler
        #'posframe-poshandler-frame-bottom-left-corner
        vertico-posframe-width 80
        vertico-posframe-height 15
        vertico-posframe-border-width 2))

(use-package vertico-directory
  :ensure nil
  :after vertico
  :bind
  (:map vertico-map
        ("DEL" . vertico-directory-delete-char)
        ("M-DEL" . vertico-directory-delete-word)))

(use-package marginalia
  :ensure nil
  :config
  (marginalia-mode))

(use-package orderless
  :ensure nil
  :init
  (setq completion-styles '(orderless basic)))

(use-package vterm
  :ensure nil
  :config
  (evil-set-initial-state 'vterm-mode 'emacs))

;;; init.el ends here
