;;; melpa.el --- install the libraries Guix lacks from MELPA; report per package -*- lexical-binding: t; -*-
(require 'package)
(setq package-user-dir (expand-file-name "elpa" user-emacs-directory)
      package-check-signature nil
      package-archives '(("melpa" . "https://melpa.org/packages/") ("gnu" . "https://elpa.gnu.org/packages/") ("nongnu" . "https://elpa.nongnu.org/nongnu/")))
(package-initialize) (package-refresh-contents)
(let (ok bad)
  (with-temp-buffer
    (insert-file-contents "/tmp/located.txt")
    (dolist (l (split-string (buffer-string) "\n" t))
      (when (string-suffix-p "absent" l)
        (let ((p (intern (car (split-string l)))))
          (condition-case e (progn (package-install p) (push p ok))
            (error (push (cons p (error-message-string e)) bad)))))))
  (princ (format "\n=== MELPA ok=%d bad=%d\nBAD %S\n" (length ok) (length bad) bad)))
