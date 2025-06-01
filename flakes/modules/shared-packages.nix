{pkgs, ...}: {
  
  # system packages
  # 
  environment.systemPackages = with pkgs; [
    
    ## zsh / posix
    zsh
    zstd
    zsh-autocomplete
    antidote
    shellcheck
    shfmt

    # tmux session / plugins
    sesh

    # pimp the cli
    gum
    skate

    ## alt shells
    nushell
    oils-for-unix
    fish
    xonsh

    ## disk / io
    duf
    pydf

    ## package management
    comma
    cachix
    devcontainer
    devenv
    manix
    alejandra
    nh
    nil
    nix-bisect
    nix-btm
    nixd
    nix-diff
    nix-direnv
    nix-du
    nix-index
    nix-inspect
    nix-melt
    nix-output-monitor
    nix-bash-completions
    nix-search-cli
    nix-search-tv
    nix-derivation
    nix-deploy
    nix-forecast
    nix-health
    # nix-janitor
    nix-top
    nix-tree
    nixfmt-rfc-style
    nvd
    pkg-config
    unixtools.nettools
    unixtools.xxd

    # network / http
    curl
    dig
    httpie
    iftop
    inetutils
    nmap
    netcat
    socat
    openssl
    oha
    sn0int
    tcpdump
    trippy
    wget
    xh
    yt-dlp

    ## files / find
    fd
    file
    findutils
    # fsearch
    fzf-zsh
    fzy
    mcfly
    ripgrep
    vgrep
    sad
    trash-cli
    semgrep 
    tree
    zoxide

    ## compression
    xz
    unar
    _7zz
    unrar
    p7zip
    unzip
    gnutar
    cpio

    ## process management
    pstree
    killall

    ## unix / text
    coreutils
    gnused
    gawk
    bat
    emacsclient-commands
    lsd
    eza
    chroma
    sd 

    ## English
    vale
    vale-ls
    aspell

    ## download / backup
    syncthing
    backblaze-b2
    aria2
    # backintime

    ## docs, notes, productivity
    tealdeer
    pinfo
    # zeal
    # dnote
    remind

    ## graphing
    d2
    graphviz
    mermaid-cli

    ## image / graphics / multimedia
    ffmpeg
    glfw
    pastel
    chafa
    ueberzugpp
    viu
    ghostscript
    latex2html

    ## fonts
    nerd-font-patcher
    fontconfig

    ## security / crypto / secrets
    nvdtools
    seclists
    git-crypt
    gpgme
    gpg-tui
    oath-toolkit
    _1password-cli

    ## servers
    caddy
    sqlite
    postgresql

    ## tasks
    tasksh
    taskwarrior3
    # taskchampion-sync-server

    ## frivolity
    neofetch
    fastfetch
    figlet
  ];
}
