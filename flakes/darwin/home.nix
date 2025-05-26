{ 
  pkgs, 
  username, 
  ...
}: {

  imports = [
    ../home/zsh.nix
    ../home/vim.nix
    ../home/programs.nix
   ];
  
  home = {
    homeDirectory = "/Users/${username}";
    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    # TODO semantic grouping

    # emacs-macport # insecure
    btop
    semgrep
    taskwarrior
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
    kitty
    lazygit
    less
    lf
    # libGL
    libclang
    libiconv
    libyaml
    lld
    lldb
    lsd
    # lunarvim
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
    nix-search-tv
    nmap
    nnn
    nushell
    odin
    ols
    overmind
    p7zip
    pixman
    pstree
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
}
