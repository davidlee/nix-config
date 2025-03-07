{
  pkgs,
  username,
  ...
}:
{

  imports = [
    ../shared/packages.nix
  ];

  # user packages
  # 
  home-manager.users.${username} = {
    home.packages = with pkgs; [
      _1password-cli
      cpuid
      cpuinfo
      x86info
      # dropbox
      dropbox-cli
      ccache
      # gnomeExtensions.allow-locked-remote-desktop 
      devcontainer
      quickemu
      dfu-util
      difftastic
      dmidecode
      dtc
      flatpak
      inetutils
      nixd
      nix-diff
      nix-index
      nix-search-cli
      nwg-look
      p7zip
      qmk-udev-rules
      sd-switch
      swww
      unixtools.nettools
      unixtools.xxd
      wbg
      wireplumber
      emacsclient-commands
      wob
      wtype

      # tui apps
      asak
      atuin
      basilk
      calcure
      cfm
      chess-tui
      cicero-tui
      crates-tui
      csv-tui
      debase
      distrobox-tui
      di-tui
      docfd
      docui
      felix-fm
      fltrdr
      fum
      gitu
      gitui
      gobang
      gomanagedocker
      gtt
      hexpatch
      hextazy
      invidtui
      isd
      jjui
      jqp
      lazyjj
      lazyjournal
      lazysql
      libcryptui
      managarr
      md-tui
      mmtui
      mprocs
      ngrrram
      otree
      play
      rainfrog
      rmpc
      russ
      rustmission
      steam-tui
      stig
      systemctl-tui
      taskflow
      task-keeper
      tasktimer
      taskwarrior-tui
      tdf
      television
      termusic
      # textual-paint
      thokr
      tray-tui
      tui-journal
      tuir
      tuisky
      tut
      vault-tasks
      vim-language-server
      vi-mongo
      wiki-tui
      xplr
      youtube-tui
      ytermusic

    ];

    programs = {
      direnv = {
        enable = true;
        enableZshIntegration = true; 
        enableBashIntegration = true; 
        nix-direnv.enable = true;
      };

      helix.defaultEditor = true;

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

      zk.enable = true;
      nushell.enable = true;
      eza.enable = true;
      git.enable = true;

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

      librewolf = {
        enable = true;
      };

      firefox = {
        enable = true;
        # enableGnomeExtensions = true;
      };

      # gnome-terminal.enable = true;

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

  # system packages
  # 
  environment.systemPackages = with pkgs; [
    _7zz
    alsa-utils
    appimage-run
    btrfs-progs
    cachix
    cpio
    dconf
    directx-headers
    directx-shader-compiler
    # dwl
    # dwlb
    ffmpeg
    file
    findutils
    fd
    # gcc
    glfw
    greetd.greetd
    greetd.tuigreet
    hdparm
    i3status
    ictree
    iftop
    iotop
    iptraf-ng
    just
    keepassxc
    killall
    libGL
    libnotify
    llvm
    lsd
    lshw
    mesa
    meson
    mods
    mpv
    nethogs
    ninja
    nix-bisect
    nix-btm
    nix-diff
    nix-du
    nix-inspect
    nix-melt
    nix-top
    nix-tree
    nh
    nmap
    nmon
    nnn
    ols
    openssl
    pciutils
    pinfo
    pipewire
    pipx
    pkg-config
    plocate
    polkit
    pstree
    pydf
    python312
    python312Packages.pywatchman
    ripgrep
    ruby
    rustup
    smartmontools
    smem
    strace
    sysstat
    sysprof
    tcpdump
    tmux
    tree
    unrar
    unzip
    usbutils 
    valgrind
    vnstat
    wget
    which
    xplr
    zls
    zsh
    zstd
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
}
