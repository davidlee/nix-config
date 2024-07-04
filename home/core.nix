{ pkgs, ... }:

{
  home.packages = with pkgs; [

      antidote # this shit even connected?
      aria2
      aspell
      autoconf
      bat
      broot
      bun
      caddy
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
      file
      fontconfig
      fzf
      gawk
      gh
      git
      gitu
      glib
      glow
      gnused
      gnutar
      graphviz
      helix
      hello
      hexyl
      htop
      httpie
      jankyborders
      jq
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
      nerdfonts
      nethack
      nil
      ninja
      nix-direnv
      nmap
      nnn
      nodejs_latest
      nushell
      overmind
      p7zip
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
      ruby
      rustup
      shortcat
      sketchybar
      socat
      sqlite
      starship
      stdenv
      syncthing
      taskwarrior
      tldr
      tmux
      tpnote
      tree
      tree-sitter
      unar
      unzip
      vit
      watchman
      wget
      which
      xz
      yazi
      yq-go
      zellij
      zip
      zk
      zoxide
      zsh
      zstd
];

  programs = {
    neovim = {
      enable = true;
      vimAlias = true;
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
    };

    # A modern replacement for ‘ls’
    # useful in bash/zsh prompt, not in nushell.
    # exa = {
    #   enable = true;
    #   enableAliases = true;
    #   git = true;
    #   icons = true;
    # };


    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
    eza.enable = true;
    git.enable = true;
    zsh.antidote.enable = true;
    zsh.dotDir = ".config/zsh";

    # skim provides a single executable: sk.
    # Basically anywhere you would want to use grep, try sk instead.
    skim = {
      enable = true;
      enableBashIntegration = true;
    };
  };
}
