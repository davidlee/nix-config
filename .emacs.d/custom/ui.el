; (set-frame-font "Inconsolata" nil t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Interface enhancements/defaults
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Mode line information
(setopt line-number-mode t) ; Show current line in modeline
(setopt column-number-mode t) ; Show column as well

(setopt x-underline-at-descent-line nil) ; Prettier underlines
(setopt switch-to-buffer-obey-display-actions t) ; Make switching buffers more consistent



(setopt show-trailing-whitespace nil) ; By default, don't underline trailing spaces
(setopt indicate-buffer-boundaries 'left) ; Show buffer top and bottom in the margin

;; Enable horizontal scrolling
(setopt mouse-wheel-tilt-scroll t)
(setopt mouse-wheel-flip-direction t)

(setq scroll-conservatively 100)
(show-paren-mode 1)
(use-package diminish
  :ensure t)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;   Tab-bar configuration
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Show the tab-bar as soon as tab-bar functions are invoked
(setopt tab-bar-show 1)

;; Add the time to the tab-bar, if visible
;(add-to-list 'tab-bar-format 'tab-bar-format-align-right 'append)
;(add-to-list 'tab-bar-format 'tab-bar-format-global 'append)
;(setopt display-time-format "%a %F %T")
;(setopt display-time-interval 1)
;(display-time-mode)

;; (use-package
;;   doom-modeline
;;   :ensure t
;;   :init
;;   (doom-modeline-mode 1))

(use-package nerd-icons
  :ensure t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  Misc. UI tweaks
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(blink-cursor-mode -1) ; Steady cursor
(pixel-scroll-precision-mode) ; Smooth scrolling
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq use-file-dialog nil)

;; Use common keystrokes by default
(cua-mode)

;; For terminal users, make the mouse more useful
(xterm-mouse-mode 1)

;; Display line numbers in programming mode
(add-hook 'prog-mode-hook 'display-line-numbers-mode)
(setopt display-line-numbers-width 3) ; Set a minimum width

;; Nice line wrapping when working with text
(add-hook
  'text-mode-hook 'visual-line-mode)

;; Modes to highlight the current line with
(let ((hl-line-hooks '(text-mode-hook prog-mode-hook)))
  (mapc (lambda (hook) (add-hook hook 'hl-line-mode)) hl-line-hooks))

; (use-package origami)

;; disable junk UI elems
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

(global-prettify-symbols-mode t)

;; beacon
(use-package beacon
  :ensure t
  :diminish beacon-mode
  :init
  (beacon-mode 1))

;; swiper
 (use-package swiper
	:ensure t
	:bind ("C-s" . 'swiper))

;;
(use-package spaceline
  :ensure t)

 (use-package powerline
	:ensure t
	:init
	(spaceline-spacemacs-theme)
	:hook
   ('after-init-hook) . 'powerline-reset)
