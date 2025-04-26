{ 
  pkgs, 
  username, 
  ...
}: {

  imports = [
    ../home/zsh.nix
   ];
  
  home = {
    homeDirectory = "/Users/${username}";
    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;

  home.packages = with pkgs; [

    # emacs-macport # insecure
    # semgrep
    # taskwarrior
    SDL
    SDL2
    SDL2_mixer
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
    cmake
    corepack_latest
    coreutils
    curl
    d2
    darwin.trash
    delta
    deno
    difftastic
    direnv
    docutils
    exercism
    eza
    fd
    file
    fontconfig
    fswatch
    fzf
    gawk
    gh
    ghc
    git
    gitu
    glfw
    glib
    glow
    gnumake
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
    libGL
    libclang
    libiconv
    libyaml
    lld
    lldb
    lsd
    lunarvim
    lynx
    markdown-oxide
    marksman
    ncdu
    nethack
    nil
    ninja
    nix-direnv
    nix-index
    nix-search-cli
    nmap
    nnn
    # nodejs_latest
    nushell
    odin
    ols
    overmind
    p7zip
    # pipx
    pixman
    # pnpm
    pstree
    # python312
    # python312Packages.pip
    python312Packages.pywatchman
    qmk
    ranger
    raylib
    rbenv
    redo-apenwarr      
    ripgrep
    ruby
    rustup
    sad
    shortcat
    skhd
    socat
    sqlite
    starship
    stdenv
    stow
    syncthing
    tldr
    tmux
    tpnote
    tree
    tree-sitter
    unar
    unzip
    vit
    vulkan-headers
    vulkan-loader
    vulkan-tools
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
    zip
    zk
    zls
    zoxide
    zsh
    zstd
    uv

  ];

  programs = {
    helix.defaultEditor = true;

    # ghostty = {
    #   enable = true;
    #   enableZshIntegration = true;
    # };

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
