;; (use-package elisp-autofmt
;;   :commands (elisp-autofmt-mode elisp-autofmt-buffer)
;;   :hook (emacs-lisp-mode . elisp-autofmt-mode))

;(setq indent-tabs-mode nil)
;(setq lisp-indent-function nil)
;(setq lisp-indent-offset 2)

(add-hook 'emacs-lisp-mode-hook
  (lambda ()
    (setq indent-tabs-mode nil)        ; Use spaces instead of tabs
    (setq lisp-indent-offset 2))) ; Set specific Lisp indentation

:x
