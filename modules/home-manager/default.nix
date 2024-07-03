 { inputs, pkgs, ... }: {
  # specify my home-manager configs
  imports = [
    # ./settings/zsh.nix
    # ./settings/kitty.nix
  ];

  # gitu = inputs.gitu.packages.${pkgs.system}.default;

  home = {
  username = "davidlee";
  homeDirectory = "/Users/davidlee";
  packages = with pkgs; [
      antidote # this shit even connected?
      aspell
      autoconf
      bat
      broot
      bun
      clangStdenv
      corepack_latest
      coreutils
      curl
      d2
      delta
      delta
      direnv
      docutils
      emacs
      exercism
      eza
      fd
      fd
      fd
      fontconfig
      fzf
      gawk
      gh
      git
      gitu
      glib
      glib
      glow
      graphviz
      helix
      hello
      hexyl
      htop
      htop
      htop
      httpie
      httpie
      jankyborders
      jq
      kakoune
      kakoune
      kitty
      less
      lf
      libclang
      libiconv
      lld
      lsd
      markdown-oxide
      marksman
      ncdu
      neovim
      neovim
      nerdfonts
      nethack
      nil
      ninja
      nix-direnv
      nnn
      nodejs_latest
      nushell
      overmind
      pipx
      pixman
      pnpm
      pstree
      python3
      python3
      qmk
      racket
      ranger
      rbenv
      ripgrep
      ripgrep
      ruby
      rustup
      rustup
      shortcat
      sketchybar
      sketchybar
      sqlite
      starship
      stdenv
      syncthing
      taskwarrior
      tldr
      tmux
      tmux
      tmux
      tpnote
      tree
      tree
      tree-sitter
      unar
      unar
      vit
      watchman
      wget
      wget
      yazi
      zellij
      zk
      zoxide
      zsh

      # obs
      # redis
      # sqlite

      # asciinema
      # awscli2
      # babashka
      # clojure
      # clojure-lsp
      # cmake
      # coursier
      # crystal
      # gd
      # gdbm
      # gettext
      # giflib
      # gmp
      # go
      # graphite2
      # harfbuzz
      # icu
      # imath
      # jansson
      # jetbrains.idea-ultimate
      # kind
      # krb5
      # kubectl
      # libavif
      # libevent
      # libidn2
      # libnghttp2
      # libpng
      # librsvg
      # libsodium
      # libssh2
      # libtasn1
      # libtiff
      # libtool
      # libunistring
      # libvmaf
      # libyaml
      # lua
      # lz4
      # lzo
      # m4
      # maven
      # metals
      # mpdecimal
      # ncurses
      # neofetch
      # nettle
      # nodejs_21
      # oniguruma
      # opam
      # openexr
      # openldap
      # openssl
      # p11-kit
      # pandoc
      # pango
      # pcre
      # pcre2
      # perl
      # pfetch
      # php
      # pkg-config
      # readline
      # rlwrap
      # rtmpdump
      # ruby
      # semgrep
      # slack
      # spotify
      # terraform
      # texinfo
      # thefuck
      # unbound
      # vim
      # vscode
      # xz
      # zoom-us
      # zstd
    ];


    sessionVariables = {
      PAGER = "less";
      CLICLOLOR = 1;
      EDITOR = "hx";
    };
  };

  programs = {
    starship = {
      enable = true;
      enableZshIntegration = true;
    };

    # bat = {
    #   enable = true;
    #   config.theme = "TwoDark";
    # };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    eza.enable = true;
    git.enable = true;
    home-manager.enable = true;
    zsh.antidote.enable = true;
    zsh.dotDir = ".config/zsh";
  };

  # programs.home-manager.enable = true;
  # programs.zsh.antidote.enable = true;

  # programs.zsh.dotDir = ".config/zsh";

  # home.file.".inputrc".source = ./settings/inputrc;

  # Don't change this when you change package input. Leave it alone.
  home.stateVersion = "24.05"; # 23.11
}
