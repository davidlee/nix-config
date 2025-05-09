{
  pkgs,
  username,
  ...
}:
{
  # system packages
  # 
  environment.systemPackages = with pkgs; [
    ## boot 
    greetd.greetd
    greetd.tuigreet

    ## zsh / posix
    zsh
    antidote
    shellcheck
    shfmt

    ## alt shells
    nushell
    oils-for-unix
    fish
    xonsh

    ## disk / io
    duf
    hdparm
    smartmontools
    pydf
    udiskie

    ## package management
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
    nix-bash-completions
    nix-search-cli
    nix-search-tv
    nix-derivation
    nix-deploy
    nix-forecast
    nix-health
    nix-janitor
    nix-top
    nix-tree
    nixfmt-rfc-style
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
    openssl
    oha
    sn0int
    tcpdump
    trippy
    unixtools.nettools
    unixtools.xxd
    vnstat
    wget
    xh
    yt-dlp
    
    ## www
    w3m-full
    lynx
    
    ## files / find
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
    # semgrep 
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
    
    ## low level / system monitoring
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
    lm_sensors

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

    ## converters
    pandoc

    ## download / backup
    syncthing
    backblaze-b2
    aria2
    backintime

    ## docs, notes, productivity
    tealdeer
    pinfo
    zeal
    dnote
    remind

    ## graphing
    d2
    graphviz

    ## image / graphics / multimedia
    ffmpeg
    glfw
    pastel
    viu

    ## fonts
    nerd-font-patcher
    fontconfig

    ## audio
    alsa-utils
    pipewire
    wireplumber
    
    ## media players
    mpv
    playerctl
    
    ## security / crypto / secrets
    nvdtools
    seclists
    git-crypt
    gpgme
    gpg-tui
    oath-toolkit
    _1password-cli
    keepassxc

    ## servers
    caddy
    sqlite
    postgresql

    ## tasks
    tasksh
    taskwarrior3
    taskchampion-sync-server

    ## frivolity
    neofetch
    fastfetch
    figlet
    fortune
    cmatrix
    nms
    openrgb-with-all-plugins

    ### libs
    glib
    libffi
    libiconv
    libyaml
    openssl
    openssl.dev
    pkg-config
    raylib
    zlib

    # windows API libs
    dotnet-runtime

  ];

  programs = {
    nix-ld.enable = true;
    dconf.enable = true;
    gnupg.agent.enable = true;
    _1password.enable = true;

    appimage.binfmt = true;
    appimage.enable = true;

    _1password-gui = {
      enable = true;
      polkitPolicyOwners = [ username ];
    };
      
    rust-motd = { # fixme
      enable = true;
      settings = {
      };
    };
    
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

      broot = {
        enable = true;
        enableZshIntegration = true;
      };
      
      mcfly = {
        enable = true;
        enableZshIntegration = true;
      };

      eza = {
        enable = true;
        enableZshIntegration = true;
      };

      lsd = {
        enable = true;
        enableZshIntegration = true;
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
