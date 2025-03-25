{ pkgs, username, ...}: {

  # imports = [
  #   ../home/zsh.nix
  #   ../home/kitty.nix
  #  ];
  

  home = {
    inherit username;
    homeDirectory = "/Users/${username}";
    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;

  packages = with pkgs; [
    darwin.trash
    sad
    semgrep
    antidote 
    aria2
    aspell
    autoconf
    bat
    broot
    bun
    caddy
    chez
    chicken
    clangStdenv
    corepack_latest
    coreutils
    curl
    d2
    delta
    difftastic
    direnv
    nix-direnv
    docutils
    deno
    emacs-macport
    exercism
    eza
    fd
    file
    fontconfig
    fzf
    fswatch
    gawk
    gh
    ghc
    glfw
    git
    gitu
    glib
    glow
    gnused
    gnutar
    graphviz
    guile
    helix
    hello
    hexyl
    htop
    httpie
    ictree
    jankyborders
    jq
    jq
    just
    kakoune
    kakoune
    kitty
    lazygit
    less
    lf
    libclang
    libiconv
    lld
    lsd
    lynx
    lunarvim
    markdown-oxide
    marksman
    ncdu
    nerdfonts
    nethack
    nil
    ninja
    nix-search-cli
    nix-index
    nmap
    nnn
    nodejs_latest
    nushell
    overmind
    redo-apenwarr      
    libGL
    SDL
    SDL2
    SDL2_mixer
    vulkan-headers
    vulkan-loader
    vulkan-tools
    gnumake
    libyaml
    odin
    lldb
    ols
    p7zip
    pipx
    pixman
    pnpm
    pstree
    cmake
    python312
    python312Packages.pywatchman
    python312Packages.pip
    qmk
    racket
    raylib
    ranger
    rbenv
    ripgrep
    ruby
    rustup
    shortcat
    skhd
    socat
    sqlite
    starship
    stdenv
    stow
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
    wezterm
    wget
    which
    xz
    yabai
    yazi
    yq-go
    zellij
    zig
    zls
    zip
    zk
    zoxide
    zsh
    zstd
  ];
  };

  programs = {
    helix.defaultEditor = true;

    neovim = {
      enable = true;
      vimAlias = true;
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [ 
        "--cmd cd" 
        "--hook pwd" 
      ];
    };

    zk.enable = true;

    zellij = {
      enableZshIntegration = true;
    };

    yazi = {
      enable = true;
      enableZshIntegration = true;
    };

    eza.enable = true;
    git.enable = true;

    direnv.enable = true;
    direnv.nix-direnv.enable = true;

    skim = {
      enable = true;
      enableBashIntegration = true;
    };
  
  };
}
