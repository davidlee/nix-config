;;; gsweep.el --- per-module init sweep in a live frame, with signal-time backtraces -*- lexical-binding: t; -*-
(require 'cl-lib)
(defun gs-frames ()
  "Short stack: named functions only, capped."
  (let (acc)
    (mapbacktrace (lambda (_e f _a _fl) (when (symbolp f) (push f acc))))
    (seq-take (seq-remove (lambda (s) (memq s '(gs-frames mapbacktrace signal error apply funcall)))
                          (nreverse acc)) 14)))
(defun gs-sweep ()
  (let* ((dir user-emacs-directory) ok failed
         (mods (with-temp-buffer
                 (insert-file-contents (expand-file-name "init.el" dir))
                 (let (acc)
                   (while (re-search-forward "^(require '\\(dl-[a-z0-9-]+\\))" nil t)
                     (push (intern (match-string 1)) acc))
                   (nreverse acc)))))
    (load (expand-file-name "early-init.el" dir) nil t)
    (dolist (m mods)
      (let (stack)
        (condition-case err
            (handler-bind ((error (lambda (_) (unless stack (setq stack (gs-frames))))))
              (require m) (push m ok))
          (error (push (list m err stack) failed)))))
    (with-temp-file "/tmp/emacs-probe/gsweep.txt"
      (insert (format "modules=%d ok=%d failed=%d features=%d\n" (length mods) (length ok) (length failed) (length features)))
      (dolist (f (reverse failed)) (insert (format "FAIL %s %S\n  stack %S\n" (nth 0 f) (nth 1 f) (nth 2 f))))
      (insert "--- WARNINGS\n")
      (when (get-buffer "*Warnings*") (insert-buffer-substring "*Warnings*")))))
(gs-sweep)
(let (stack)
  (condition-case e
      (handler-bind ((error (lambda (_) (unless stack (setq stack (gs-frames))))))
        (load-theme 'foxglove-dark t))
    (error (with-temp-file "/tmp/emacs-probe/fox.txt" (insert (format "%S\n%S\n" e stack))))))
(with-temp-file "/tmp/emacs-probe/gui-extra.txt"
  (insert (format "meow-global %s\ndefault-font %s\n" (bound-and-true-p meow-global-mode) (face-attribute 'default :family)))
  (insert (format "treesit-missing %S\n" (seq-remove #'treesit-language-available-p
     '(bash c cpp css go html javascript json nix nu python rust toml tsx typescript typst yaml zig markdown))))
  (insert (format "fonts-missing %S\n" (seq-remove (lambda (f) (find-font (font-spec :family f)))
     '("JetBrainsMono Nerd Font Mono" "MonoLisa Nerd Font Mono" "DejaVu Sans Mono" "Geist Mono" "Source Sans 3" "Noto Sans"))))
  (insert (format "exes-missing %S\n" (seq-remove #'executable-find
     '("rg" "fd" "git" "just" "direnv" "zig" "node" "claude" "pi" "doctrine" "bough" "op" "gcc" "cc" "cmake" "make" "enchant-2" "sdcv" "typst" "tinymist" "nixd" "nix" "nu" "statix")))))
(write-region "" nil "/tmp/emacs-probe/gui-done")
