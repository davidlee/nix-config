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
    
    # boot 
    greetd.greetd
    greetd.tuigreet

    # zsh / posix
    zsh
    antidote
    shellcheck
    shfmt

    # alt shells
    nushell
    oils-for-unix
    fish
    xonsh

    # disk / io
    duf
    hdparm
    smartmontools
    pydf
    udiskie

    # package management
    comma
    appimage-run
    cachix
    devcontainer
    devenv
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
    nix-output-monitor
    nix-search-cli
    nix-top
    nix-tree
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
    netcat
    socat
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
    yt-dlp
    # www
    w3m-full
    lynx
    
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

    # unix / text
    coreutils
    gnused
    gawk
    aspell
    bat
    emacsclient-commands
    lsd
    eza
    chroma

    # json/yaml
    jq
    yq-go
    # convert
    pandoc

    # download / backup
    syncthing
    backblaze-b2
    aria2
    backintime

    # markdown
    markdownlint-cli
    markdownlint-cli2
    markdown-oxide
    marksman

    # pdf

    # docs, notes, productivity
    tealdeer
    pinfo
    zeal
    dnote
    remind

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

    # media 
    playerctl
    ffmpeg

    # wine etc
    wine
    wineWowPackages.stagingFull
    winetricks
    wine-wayland
    wine-staging

    #
    # libs
    # 
    # - graphic  
    openssl
    openssl.dev
    pkg-config
    libxkbcommon
    directx-headers
    vulkan-headers
    vulkan-loader
    vulkan-tools
    raylib
    libGL.dev
    # wayland-scanner
    xorg.libX11
    xorg.libX11.dev
    xorg.libXcursor
    xorg.libXi
    xorg.libXinerama
    xorg.libXrandr

    # - misc 
    polkit
    libyaml
    libffi
    glib
    libiconv
    libnotify
    emscripten

  ];

  programs = {
    _1password.enable = true;

    _1password-gui = {
      enable = true;
      polkitPolicyOwners = [ username ];
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
    programs = {
      helix.defaultEditor = true;

      eza.enable = true;
      firefox.enable = true;
      git.enable = true;
      librewolf.enable = true;
      nushell.enable = true;
      fish.enable = true;
      cava.enable = true;

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
        options = [ 
          "--cmd cd" 
          "--hook pwd" 
        ];
      };

      carapace = {
        enable = true;
        enableZshIntegration = true;
        enableNushellIntegration = true;
      };

      atuin = {
        enable = true;
        enableFishIntegration = true;
        enableNushellIntegration = true;
        flags = [ "--disable-up-arrow" ];
        settings = {
          show_tabs = false;
          style = "compact";
        };
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
