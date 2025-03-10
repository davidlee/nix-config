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
    sad
    semgrep
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
    just

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

    # lang.zig
    zig
    zls

    # lang.python
    pipx
    python313Packages.pywatchman
    python313Packages.pip
    docutils
    meson

    #lang.rust
    rustup

    # lang.shell
    antidote
    nushell
    shellcheck
    shfmt
    zsh
    zstd

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

    # download / backup
    syncthing
    backblaze-b2
    aria2

    # json/yaml
    jq
    yq-go

    # vcs 
    gh
    git 
    delta
    difftastic
    jujutsu

    # emulation / virtualisation
    qemu
    quickemu

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

    # servers
    caddy
    sqlite
    postgresql
  ];

  programs = {
    nix-ld.enable = true;
    dconf.enable = true;
  
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [thunar-archive-plugin thunar-volman];
    };

    zsh.enable = true;
  };

  # allow non-root write access to firmware 
  hardware = {
    keyboard.qmk.enable = true;
  };

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
        enableNushellIntegration = true;
        settings = {
          add_newline = false;
          buf = {symbol = " ";};
          c = {symbol = " ";};
          directory = {read_only = " 󰌾";};
          docker_context = {symbol = " ";};
          fossil_branch = {symbol = " ";};
          git_branch = {symbol = " ";};
          golang = {symbol = " ";};
          hg_branch = {symbol = " ";};
          hostname = {ssh_symbol = " ";};
          lua = {symbol = " ";};
          memory_usage = {symbol = "󰍛 ";};
          meson = {symbol = "󰔷 ";};
          nim = {symbol = "󰆥 ";};
          nix_shell = {symbol = " ";};
          nodejs = {symbol = " ";};
          ocaml = {symbol = " ";};
          package = {symbol = "󰏗 ";};
          python = {symbol = " ";};
          rust = {symbol = " ";};
          swift = {symbol = " ";};
          zig = {symbol = " ";};
        };
      };
    };
  };
}
