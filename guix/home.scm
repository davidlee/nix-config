;; Guix Home for Guix System hosts.  Tracked in the home repo beside
;; flakes/, which does the same job on Nix hosts.  The dotfiles are shared;
;; this file supplies packages and the per-system stubs that load them.
;;
;; Apply: guix home reconfigure ~/guix/home.scm
(define-module (guix-home-config)
  #:use-module (gnu home)
  #:use-module (gnu home services)
  #:use-module (gnu home services shells)
  #:use-module (gnu home services ssh)
  #:use-module (gnu services)
  #:use-module (gnu packages)
  #:use-module (gnu system shadow)
  #:use-module (guix gexp)
  #:use-module (guix transformations))

(define-macro (package-list symbols)
  `(map (lambda (name) 
          (specification->package (symbol->string name)))
        ,symbols))


;; Packages for ~/.config/emacs. The reference list is ~/flakes/emacs/emacs.nix
;; on the host; what Guix lacks comes from `just guix-packages' in that repo.
(define emacs-tools
  '(
    emacs-pgtk guile ripgrep fd git just direnv gcc-toolchain
    enchant font-nerd-jetbrains-mono font-google-noto
    font-adobe-source-sans))

;; Tools the shared dotfiles assume.
(define dotfile-tools
  '(
    git-delta))                         ; ~/.gitconfig pager

(define tree-sitter-grammars
  '(
    tree-sitter-bash tree-sitter-cpp tree-sitter-css tree-sitter-go
    tree-sitter-html tree-sitter-javascript tree-sitter-json
    tree-sitter-nix tree-sitter-python tree-sitter-rust
    tree-sitter-toml tree-sitter-typescript tree-sitter-yaml
    tree-sitter-zig))

(define emacs-packages
  '(
    emacs-ace-window emacs-agent-shell emacs-aggressive-indent
    emacs-all-the-icons emacs-apheleia emacs-atomic-chrome emacs-avy
    emacs-beacon emacs-cape emacs-compile-angel emacs-consult
    emacs-consult-eglot emacs-consult-notes emacs-corfu emacs-crux
    emacs-dash emacs-deadgrep emacs-denote emacs-denote-explore
    emacs-denote-org emacs-diff-hl emacs-diminish
    emacs-dired-sidebar emacs-diredfl emacs-direnv emacs-dirvish
    emacs-doom-themes emacs-dumb-jump emacs-dwim-shell-command
    emacs-eat emacs-ef-themes emacs-elfeed emacs-elisp-demos
    emacs-elpher emacs-embark emacs-emcp emacs-envrc emacs-eros
    emacs-expand-region emacs-expreg emacs-flycheck
    emacs-flymake-flycheck emacs-geiser emacs-geiser-guile
    emacs-git-link emacs-git-modes emacs-go-mode emacs-goto-chg
    emacs-gptel emacs-gptel-agent emacs-grip-mode
    emacs-gruvbox-theme emacs-helpful emacs-highlight-defined
    emacs-highlight-numbers emacs-highlight-quoted emacs-hl-todo
    emacs-hydra emacs-iedit emacs-jinx emacs-json-mode
    emacs-kind-icon emacs-kirigami emacs-kkp emacs-leaf
    emacs-ligature emacs-magit emacs-marginalia emacs-markdown-mode
    emacs-markdown-preview-mode emacs-mcp emacs-meow
    emacs-meow-tree-sitter emacs-move-text emacs-nano-modeline
    emacs-nano-theme emacs-nerd-icons emacs-nerd-icons-completion
    emacs-nerd-icons-dired emacs-nix-mode emacs-olivetti
    emacs-orderless emacs-org-bullets emacs-org-modern
    emacs-org-notify emacs-org-ql emacs-org-roam
    emacs-outline-indent emacs-package-lint emacs-persp-mode
    emacs-popper emacs-posframe emacs-powerthesaurus emacs-prescient
    emacs-puni emacs-rainbow-delimiters emacs-rainbow-mode
    emacs-relint emacs-rg emacs-s emacs-shackle emacs-smudge
    emacs-solaire-mode emacs-spacious-padding emacs-standard-themes
    emacs-suggest emacs-super-save emacs-telephone-line emacs-tempel
    emacs-tldr emacs-tmr emacs-transient emacs-transpose-frame
    emacs-treemacs emacs-treesit-auto emacs-typst-ts-mode
    emacs-undercover emacs-undo-fu emacs-undo-fu-session
    emacs-vertico emacs-vterm-toggle emacs-vundo emacs-wgrep
    emacs-ws-butler emacs-yaml-mode))

;; Guix's releases are too old for this config.
(define use-upstream-emacs-packages
  (options->transformation
   '((with-branch . "emacs-meow=master")
     (with-branch . "emacs-solaire-mode=master"))))

(define home-config
  (home-environment
   (packages
    (map use-upstream-emacs-packages
         (package-list (append emacs-tools dotfile-tools tree-sitter-grammars
                               emacs-packages))))
   
   (services
      (append
        (list
          (service home-zsh-service-type)

          (service home-ssh-agent-service-type)

          (service home-files-service-type
           `((".guile" ,%default-dotguile)
             (".Xdefaults" ,%default-xdefaults)))

          (service home-xdg-configuration-files-service-type
           `(("gdb/gdbinit" ,%default-gdbinit)
             ("nano/nanorc" ,%default-nanorc)
             ;; Guix owns the stub; the shared config is ~/.config/sway/sway.conf.
             ("sway/config"
              ,(plain-file "sway-config" "include $HOME/.config/sway/sway.conf\n")))))

        %base-home-services))))


home-config
