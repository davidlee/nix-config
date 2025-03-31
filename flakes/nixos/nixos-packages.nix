{
  pkgs,
  username,
  ...
}:
{
  # system packages
  # 
  environment.systemPackages = with pkgs; [
    # secrets 
    _1password-cli
    keepassxc

    # libs 
    polkit
    directx-headers
    glib
    libffi
    libGL
    libiconv
    libyaml
    vulkan-headers
    vulkan-loader
    vulkan-tools
    raylib
    libGL
    libnotify
    
    # boot 
    greetd.greetd
    greetd.tuigreet

    # disk / io
    duf
    hdparm
    smartmontools
    iotop
    pydf

    # package management
    appimage-run
    cachix
    devcontainer
    flatpak
    manix
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
    nix-search-cli
    nix-search-cli
    nix-top
    nix-tree
    nix-output-monitor
    nix-bash-completions
    nixfmt-rfc-style
    # nixfmt-tree
    nvd
    pkg-config
    sd-switch
    unixtools.nettools
    unixtools.xxd

    # network / http
    curl
    dig
    httpie
    iftop
    inetutils
    iptraf-ng
    nethogs
    nmap
    nmon
    oha
    openssl
    sn0int
    tcpdump
    trippy
    unixtools.nettools
    unixtools.xxd
    vnstat
    wget
    xh
    
    # files / find
    fd
    file
    findutils
    fsearch
    fzf-zsh
    fzy
    mcfly
    plocate
    ripgrep
    vgrep
    sad
    trash-cli
    # semgrep # FIXME busted 
    tree
    zoxide

    # compression
    xz
    unar
    _7zz
    unrar
    p7zip
    unzip
    gnutar
    cpio

    # process management
    pstree
    killall

    # programming general
    lldb
    valgrind
    direnv
    exercism
    tree-sitter
    overmind
    watchman
    zeal
    just
    dnote
    gofumpt # go formatter
    # nickel
    # nls

    # www
    html-tidy
    prettierd
    
    # low level / system monitoring
    ccache
    cpuid
    cpuinfo
    dmidecode
    lshw
    pciutils
    smem
    stress-ng
    sysprof
    sysstat
    usbutils 
    x86info

    # build
    gnumake
    ninja

    # lang.c
    bison
    lld
    llvm
    strace
    stdenv
    gcc

    # lang.zig
    zig
    zls

    # lang.python
    pipx
    python313Packages.pywatchman
    python313Packages.pip
    docutils
    meson

    # lang.shell
    antidote
    nushell
    oils-for-unix
    fish
    shellcheck
    shfmt
    xonsh
    zsh

    # unix / text
    coreutils
    gnused
    gawk
    aspell
    less
    bat
    emacsclient-commands
    lsd
    eza
    ov
    chroma
    viddy

    # download / backup
    syncthing
    backblaze-b2
    aria2
    backintime

    # json/yaml
    jq
    yq-go

    # vcs 
    gh
    git 
    hub
    delta
    difftastic
    diffnav
    jujutsu
    sublime-merge
    meld
    diffr
    diffsitter
    diffstat
    diffedit3
    diffoscope
    mergiraf


    # emulation / virtualisation
    qemu
    quickemu
    # darling 

    # session manager
    zellij
    tmux

    # markdown
    markdownlint-cli
    markdownlint-cli2
    markdown-oxide
    marksman

    # info
    tealdeer
    pinfo

    # image / graphics / multimedia
    alsa-utils
    d2
    directx-shader-compiler
    ffmpeg
    fontconfig
    glfw
    graphviz
    mesa
    mpv
    nerd-font-patcher
    pastel
    pipewire
    viu
    wireplumber

    # keyboard firmware
    qmk-udev-rules
    dfu-util
    qmk
    dtc

    # security
    nvdtools
    seclists
    git-crypt
    gpgme
    gpg-tui
    oath-toolkit

    # servers
    caddy
    sqlite
    postgresql
  ];

  programs = {
    _1password.enable = true;

    _1password-gui = {
      enable = true;
      polkitPolicyOwners = ["david"];
    };
      
    nix-ld.enable = true;
    dconf.enable = true;
    gnupg.agent.enable = true;
  
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [thunar-archive-plugin thunar-volman];
    };

    foot = {
      enable = true;
      theme = "gruvbox-dark";
    };

    zsh = {
      enable = true;
    };
  };

  # allow non-root write access to firmware 
  hardware = {
    keyboard.qmk.enable = true;
  };

  ##              ##
  ## HOME MANAGER ##
  ##              ##

  # user packages
  # 
  home-manager.users.${username} = {
    home.packages = with pkgs; [
      # lang.odin
      ols

      # lang.ruby
      ruby

      # lang.lua
      lua
      lua54Packages.luarocks-nix 
      vimPlugins.fzf-lua
      lua-language-server
      luarocks-packages-updater

      # lang.js
      bun
      pnpm
      corepack_latest
      nodejs_latest
      typescript-language-server
      typescript

      # download / backup
      yt-dlp

      # tasks
      tasksh
      taskwarrior3
      taskchampion-sync-server

      # frivolity
      neofetch
      fastfetch

      # ai 
      ollama
      oterm
      aichat
      local-ai
      mods
    ];

    programs = {
      helix.defaultEditor = true;

      eza.enable = true;
      firefox.enable = true;
      git.enable = true;
      librewolf.enable = true;
      nushell.enable = true;
      fish.enable = true;

      zk.enable = true;

      direnv = {
        enable = true;
        enableZshIntegration = true; 
        enableBashIntegration = true; 
        nix-direnv.enable = true;
      };

      neovim = {
        enable = true;
        vimAlias = true;
      };

      fzf = {
        enable = true;
        enableZshIntegration = true;
      };

      zoxide = {
        enable = true;
        enableZshIntegration = true;
        enableNushellIntegration = true;
        # options = [ 
        #   "--cmd cd" 
        #   "--hook pwd" 
        # ];
      };

      carapace = {
        enable = true;
        enableZshIntegration = true;
        enableNushellIntegration = true;
      };


      zellij = {
        enableZshIntegration = true;
      };

      yazi = {
        enable = true;
        enableZshIntegration = true;
      };

      skim = {
        enable = true;
        enableBashIntegration = true;
      };

      starship = {
        enable = true;
        enableZshIntegration = true;
        settings = pkgs.lib.importTOML ../files/starship.toml // {
          scan_timeout = 100;
          command_timeout = 750;
        };
      };
    };
  };

  environment.pathsToLink = [ "/share/zsh" ];
}
