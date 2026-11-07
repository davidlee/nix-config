;;; dump.el --- report post-init state to a file -*- lexical-binding: t; -*-
(defun probe-dump ()
  (with-temp-file "/tmp/emacs-probe/gui-state.txt"
    (insert (format "init-time %s\nfeatures %d\nwindow-system %s\ntheme %S\nfont %s\nmeow-global %s\nerror-buffers %S\n"
                    (emacs-init-time) (length features) window-system custom-enabled-themes
                    (face-attribute 'default :family)
                    (bound-and-true-p meow-global-mode)
                    (mapcar #'buffer-name (buffer-list))))
    (insert "--- WARNINGS\n")
    (when (get-buffer "*Warnings*") (insert-buffer-substring "*Warnings*"))
    (insert "--- MESSAGES\n")
    (insert-buffer-substring "*Messages*"))
  (write-region "" nil "/tmp/emacs-probe/gui-done"))
(run-at-time 20 nil #'probe-dump)
(defun probe-extra ()
  (with-temp-file "/tmp/emacs-probe/gui-extra.txt"
    (insert (format "meow-global %s\ntreesit-missing %S\nfonts-missing %S\nmissing-exes %S\n"
      (bound-and-true-p meow-global-mode)
      (seq-remove #'treesit-language-available-p
        '(bash c cpp css go html javascript json nix nu python rust toml tsx typescript typst yaml zig elisp markdown))
      (seq-remove (lambda (f) (find-font (font-spec :family f)))
        (mapcar #'cdr (bound-and-true-p my/fonts)))
      (seq-remove #'executable-find
        '("rg" "fd" "git" "just" "direnv" "zig" "node" "claude" "pi" "doctrine" "bough" "op" "gcc" "cc" "cmake" "make" "enchant-2" "sdcv" "typst" "tinymist" "nixd" "nix" "nu" "aspell" "statix" "nixfmt"))))))
  (condition-case e (let ((debug-on-error t)) (load-theme 'foxglove-dark t))
    (error (with-temp-file "/tmp/emacs-probe/fox.txt" (insert (format "%S\n%s" e (with-output-to-string (backtrace))))))))
(run-at-time 15 nil #'probe-extra)
