;;; Emacs Bedrock
;;;
;;; Extra config: Vim emulation

;;; Usage: Append or require this file from init.el for bindings in Emacs.

;;; Contents:
;;;
;;;  - Core Packages

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Core Packages
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Evil: vi emulation
(use-package evil
  :ensure t

  :init
  (setq evil-respect-visual-line-mode t)
  (setq evil-undo-system 'undo-redo)
  (setq evil-want-integration t
    evil-want-integration t
    evil-want-keybinding nil
    evil-want-C-u-scroll t
    evil-want-C-i-jump nil)
  
  (setq evil-insert-state-cursor '((bar . 5) "red"))
  (setq evil-normal-state-cursor '((bar . 5) "white"))
  (setq evil-visual-state-cursor '((box. 5) "purple"))
  (setq evil-motion-state-cursor '((box . 5) "green"))
  (setq evil-operator-state-cursor '((box . 5) "blue"))
  (setq evil-replace-state-cursor '((box . 5) "yellow"))
 
  ;; Enable this if you want C-u to scroll up, more like pure Vim
  ;(setq evil-want-C-u-scroll t)

  :config
  (evil-mode 1)
 
  ;; If you use Magit, start editing in insert state
  (add-hook 'git-commit-setup-hook 'evil-insert-state)

  (evil-set-leader '(normal motion visual) (kbd "<SPC>"))
  (evil-define-key 'normal 'global (kbd "<leader>fs") 'save-buffer)
  (evil-define-key 'normal 'global (kbd "<leader>ff") 'consult-buffer)
  
  ;; Configuring initial major mode for some modes
  (evil-set-initial-state 'eat-mode 'emacs)
  (evil-set-initial-state 'vterm-mode 'emacs))

(use-package evil-collection
  :ensure (:host github :repo "emacs-evil/evil-collection")
  :after evil
  :config
  (evil-collection-init))

