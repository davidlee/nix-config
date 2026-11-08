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
  #:use-module (guix transformations)
  #:use-module (guix git)
  #:use-module (ice-9 match))

;; Package names (symbols, optionally with an output, e.g. bind:utils)
;; to package/output pairs, with the upstream-branch transformations applied.
(define (package-list symbols)
  (map (match-lambda
         ((package output) (list (use-upstream-emacs-packages package) output)))
       (specifications->packages (map symbol->string symbols))))


;; Packages for ~/.config/emacs. The reference list is ~/flakes/emacs/emacs.nix
;; on the host; what Guix lacks comes from `just guix-packages' in that repo.
(define emacs-tools
  '(
    emacs-pgtk guile ripgrep fd git just direnv gcc-toolchain
    enchant hunspell-dict-en-au font-nerd-jetbrains-mono font-google-noto
    font-adobe-source-sans))

;; Tools the shared dotfiles assume: ~/.gitconfig, ~/.config/zsh, sway.conf.
;; Not in Guix: ov ($PAGER), carapace, television, lazygit, ghostty,
;; swayosd, sway-launcher-desktop.  See probes/packages.tsv.
(define dotfile-tools
  '(
    git-delta fzf eza bat atuin tmux zoxide yazi most))

;; The rest of the Nix host's command-line set (~/flakes), where Guix has it.
(define cli-tools
  '(
    7zip aria2 asciinema aspell ast-grep bc bfs bind:utils bottom btop
    cfm chafa cmatrix cmus curl curlie diffr diffstat difftastic du-dust
    entr ffmpeg figlet file fortunes-jkirchartz fswatch fzy gdu
    github-cli git-crypt gitui glances gnupg go-jqp gron hexyl htop
    hyperfine iftop jc jless jq jujutsu lf lsd lsof lynx mc mediainfo
    mergiraf micro moreutils ncdu nmap nnn nushell oath-toolkit pastel
    pinfo playerctl poppler procs psmisc pueue pydf qrencode ranger resvg
    ripgrep-all rsync sc-im sd sdcv shellcheck shfmt skim socat strace
    stress-ng tcpdump tealdeer tig tokei trash-cli tree-sitter-cli
    ueberzugpp unrar unzip vips w3m watchexec wget xxd yq yt-dlp zip
    zstd))
;; Skipped for now:
;; - fastfetch: its optional ZFS support builds zfs from source.
;; Sizes (2026-11-08, closure added on top of the rest): pandoc, used by
;; ~/.config/emacs/org/dl-org.el, adds ~4 GiB of Haskell libraries, and
;; ripgrep-all shares it.  They are the first cut if disk runs short.

(define dev-tools
  '(
    autoconf bison ccache cmake exercism ghostscript graphviz helix
    kakoune kak-lsp latex2html lem make mise mold neovim ninja
    node pandoc python texlive-scheme-basic typst uv))

;; The sway session (sway itself is a system package).
(define desktop-tools
  '(
    firefox foot fuzzel grim grimshot imv kanshi kitty mpv signal-desktop
    slurp swaybg swayidle swaylock-effects swaynotificationcenter swayr
    udiskie waybar wev wl-clipboard wofi yad zathura))
;; Skipped GUI apps, for disk (VM: 54 GB).  Added size in MiB on top of the
;; rest, 2026-11-08.  sway.conf autostarts both.
;; - copyq (+287, Qt): clipboard manager; sway.conf autostarts it.
;; - flameshot (+110, Qt): screenshots; grimshot covers $mod+z.
;; - Not measured (inferred large): blender gimp inkscape krita mypaint drawpile
;;   openscad obs ungoogled-chromium librewolf epiphany icedove zed
;;   element-desktop vlc celluloid fsearch mangohud signal-cli spotifyd
;;   syncthing.

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

;; Stubs that load the shared ~/.config/zsh files, in the order home-manager
;; uses on the Nix host (~/flakes/features/terminal/zsh.nix).  Guix writes
;; them to ~/.config/zsh (ZDOTDIR), after its own profile setup.
(define zsh-stubs
  (home-zsh-configuration
   (zshenv
    (list (plain-file "zshenv" "\
source $HOME/.config/zsh/env.zsh
(( $+commands[ov] )) || export PAGER=less
")))
   (zprofile
    (list (plain-file "zprofile" "source $HOME/.config/zsh/profile.zsh\n")))
   (zshrc (list (local-file "zsh/zshrc")))
   (zlogin
    (list (plain-file "zlogin" "source $HOME/.config/zsh/login.zsh\n")))
   (zlogout
    (list (plain-file "zlogout" "source $HOME/.config/zsh/logout.zsh\n")))))

;; Plugin manager for ~/.config/zsh/.zsh_plugins.txt; pinned to the Nix
;; host's clone.  Plugins themselves are cloned at runtime into ~/.cache.
(define antidote
  (git-checkout
   (url "https://github.com/mattmc3/antidote.git")
   (commit "ed83f88722bf6d82f7f04a765fbf01ca025f2efb")))

(define home-config
  (home-environment
   (packages
    (package-list (append emacs-tools dotfile-tools cli-tools dev-tools
                          desktop-tools tree-sitter-grammars emacs-packages)))
   
   (services
      (append
        (list
          (service home-zsh-service-type zsh-stubs)

          (service home-ssh-agent-service-type)

          (service home-files-service-type
           `((".guile" ,%default-dotguile)
             (".Xdefaults" ,%default-xdefaults)))

          (service home-xdg-configuration-files-service-type
           `(("gdb/gdbinit" ,%default-gdbinit)
             ("nano/nanorc" ,%default-nanorc)
             ;; initEarly.zsh sources it; the Nix host has a manual clone.
             ("zsh/.antidote" ,antidote)
             ;; Guix owns the stub; the shared config is ~/.config/sway/sway.conf.
             ("sway/config"
              ,(plain-file "sway-config" "include $HOME/.config/sway/sway.conf\n")))))

        %base-home-services))))


home-config
