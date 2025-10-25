;; EMACS - a configuration adventure
;;

;; Show the help buffer after startup
; (add-hook 'after-init-hook 'help-quick)

;; which-key: shows a popup of available keybindings when typing a long key
;; sequence (e.g. C-x ...)
(use-package which-key
  :ensure t
  :diminish which-key-mode
  :config
  (which-key-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; elpaca setup
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(elpaca elpaca-use-package (elpaca-use-package-mode))

;; hook for anything which needs to run after all packagees are loaded
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(add-hook
 'elpaca-after-init-hook (lambda () (load custom-file 'noerror)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Theme
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; (use-package emacs
;;   :config
;;   ;(load-theme 'modus-vivendi))          ; for light theme, use modus-operandi
;;   (load-theme 'modus-vivendi))          ; for light theme, use modus-operandi

(use-package 
  standard-themes 
  :ensure t 
  :init

  (standard-themes-take-over-modus-themes-mode 1)
  :bind
  (("<f5>" . modus-themes-rotate)
    ("C-<f5>" . modus-themes-select)
    ("M-<f5>" . modus-themes-load-random))
  
  :config
  (setq modus-themes-mixed-fonts t)
  (setq modus-themes-italic-constructs t)


  (modus-themes-load-theme 'standard-dark)) 

;; (use-package modus-themes
;;   :ensure t
;;   :init

;;   :bind
;;   :config)

;(use-package ef-themes
;;  :ensure t
;;  :init
;; (ef-themes-take-over-modus-themes-mode 1)
;;  :bind
;;  :config
;;  (setq modus-themes-mixed-fonts t)
;;  (setq modus-themes-italic-constructs t)

;;  (modus-themes-load-theme 'ef-owl))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Custom
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun load-custom-list (list)
  (let (value)
    (dolist (elem list value)
      (load-file
        (expand-file-name (concat "custom/" elem ".el")
          user-emacs-directory)))))

(load-custom-list
  '("keys"
     "ui"
     "save"
     "elisp"
     "motion"
     "power-ups"
     "editing"
     "minibuffer-completion"
     "dev"
     "eglot"
     "eshell"
     "filetypes"
     "org"
     "qol"
     ))

                                        ; vile 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Extras
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; Email configuration in Emacs
;; WARNING: needs the `mu' program installed; see the elisp file for more
;; details.
;(load-file (expand-file-name "extras/email.el" user-emacs-directory))

;; Tools for academic researchers
(load-file
 (expand-file-name "extras/researcher.el" user-emacs-directory))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Built-in customization framework
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance. 
 ;; If there is more than one, they won't work right.
  '(package-selected-packages nil))



(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
  )

;;
;; FONTS
;;

(setq gc-cons-threshold (or bedrock--initial-gc-threshold 800000))
;(add-to-list 'default-frame-alist '(font . "Zed Mono Nerd Font Mono"))
(add-to-list 'default-frame-alist '(font . "Mononoki Nerd Font Mono"))

;; (dolist (font (x-list-fonts "*"))
;;   (insert (format "%s\n" font)))
