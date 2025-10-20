{lib, ...}: let
  #
  # helpers for reducing all of the cli packages
  #
  collectSharedPackages = config:
    lib.lists.foldl (a: x: a ++ x)
    []
    (lib.attrsets.attrValues config.sharedCliPackages);

  collectNixosPackages = config:
    lib.lists.foldl (a: x: a ++ x)
    []
    (lib.attrsets.attrValues config.nixosCliPackages);
in {
  flake.flakeModules.cliPackages = {
    pkgs,
    lib,
    ...
  }: let
    props = [
      "shells"
      "zsh"
      "pagers"
      "find"
      "fileutils"
      "system"
      "build"
      "scm"
      "security"
      "supervisors"
      "help"
      "display"
      "net"
      "dev"
      "help"
      "viewers"
      "unix"
      "filetypes"
      "frivolity"
      "www"
    ];
  in {
    # DRY'er but less explicit & positional args kinda suck

    # setPackages = category: shared: nixos: {
    #   sharedCliPackages.${category} = shared;
    #   nixosCliPackages.${category} = nixos;
    # };
    #
    # usage:
    #
    #   (setPackages "example" (with pkgs; [
    #     ]) (with pkgs; [
    #     ]))

    #
    # use props above to build out type safe options
    #

    options.sharedCliPackages = lib.genAttrs props (name:
      lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [];
      });

    options.nixosCliPackages = lib.genAttrs props (name:
      lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [];
      });

    ################################################################################
    #
    # template
    #
    # config.sharedCliPackages.template = with pkgs; [];
    # config.nixosCliPackages.template = with pkgs; [];

    ################################################################################
    #
    # zsh
    #
    config.sharedCliPackages.zsh = with pkgs; [
      ## zsh / posix
      zsh
      zstd
      zsh-autocomplete
      antidote
      shellcheck
      shfmt
      ## zsh config depends on
      starship
      carapace
      eza
      lsd
      fzf
      atuin
      zoxide
      yazi
      broot
      tmux
      sesh
      skim
      delta
      bfs #faster than fd
      ## unix / text
      coreutils
      gnused
      gawk
      bat
      sd
      aspell
      play # playground for sed, grep, awk, ...
      # also lovely
      trash-cli
      bat
      jless
      gdu
      ncdu
      hyperfine
      jq
      sd
      gron
      await
      xh
      doggo
      curlie
      httpie
      trashy
      procs
      pls
      dust
      clock-rs
      choose
      glances
      gtop
      cheat
      duf
      tldr
      tre
      pueue
      grex
      tree
    ];
    config.nixosCliPackages.zsh = with pkgs; [
    ];

    ################################################################################
    #
    # help
    #
    config.sharedCliPackages.help = with pkgs; [
    ];
    config.nixosCliPackages.help = with pkgs; [
      tldr
      tealdeer
      zeal
      pinfo
    ];

    ################################################################################
    #
    # build
    #
    config.sharedCliPackages.build = with pkgs; [
      ## build tools
      gnumake
      ninja
      autoconf
      cmake
      # redo-apenwarr

      ## parse / lex
      bison

      ## lang.c
      lldb
      lld
      llvm
      gcc
      clangStdenv
      libclang
    ];
    config.nixosCliPackages.build = with pkgs; [
    ];

    ################################################################################
    #
    # system
    #
    config.sharedCliPackages.system = with pkgs; [
      glances
      btop
    ];
    config.nixosCliPackages.system = with pkgs; [
      ## disk & file io
      mmtui # mount manager
      ## disk / io
      hdparm
      smartmontools
      udiskie

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
      mprocs # parallel command runner
      tray-tui # systray
      ## download / backup
      backintime
      ## sysmon
      lm_sensors
      atop
      iotop
      bottom
      htop
      gtop
      ## system utils
      isd # systemd
      lazyjournal # logs & containers
      systemctl-tui
    ];

    ################################################################################
    #
    # fileutils
    #
    config.sharedCliPackages.fileutils = with pkgs; [
      ## file managers
      broot
      cfm
      felix-fm
      ictree
      nnn
      ranger
      xplr
      yazi
      lf
      superfile

      ## disk & file io
      ncdu
      gdu
      duf
      pydf

      ## compression
      xz
      unar
      _7zz
      unrar
      p7zip
      unzip
      gnutar
      cpio
      zip

      ## download / backup
      syncthing
      backblaze-b2
      aria2
      # backintime
    ];
    config.nixosCliPackages.fileutils = with pkgs; [
    ];

    ################################################################################
    #
    # net
    #
    config.sharedCliPackages.net = with pkgs; [
      # network / http
      curl
      curlie
      dig
      ngrok
      httpie
      iftop
      inetutils
      nmap
      netcat
      socat
      openssl
      oha
      tcpdump
      trippy
      wget
      xh
      yt-dlp
    ];
    config.nixosCliPackages.net = with pkgs; [
      sn0int
      iptraf-ng
      nethogs
      nmon
      vnstat
    ];

    ################################################################################
    #
    # find
    #
    config.sharedCliPackages.find = with pkgs; [
      ## file find & search
      docfd
      television
      nix-search-tv
      nix-search-cli
      fd
      file
      findutils
      fzf-zsh
      fzy
      mcfly
      ripgrep
      vgrep
      sad
      zoxide
      ast-grep
      findutils
      ripgrep-all
    ];
    config.nixosCliPackages.find = with pkgs; [
      semgrep
      ast-grep
      fsearch
      plocate
      # fsearch
    ];

    ################################################################################
    #
    # scm
    #
    config.sharedCliPackages.scm = with pkgs; [
      git
      delta
      diffedit3
      diffnav
      diffr
      diffstat
      difftastic
      gh
      gitFull
      hub
      jujutsu
      mergiraf
      tig
      debase
      gh-dash
      lazygit
      lazyjj
      jjui
    ];
    config.nixosCliPackages.scm = with pkgs; [
    ];

    ################################################################################
    #
    # dev
    #
    config.sharedCliPackages.dev = with pkgs; [
      just
      exercism
    ];
    config.nixosCliPackages.dev = with pkgs; [
      # ## lang.c
      valgrind
      strace
    ];

    ################################################################################
    #
    # security
    #
    config.sharedCliPackages.security = with pkgs; [
      #
      ## security / crypto / secrets
      nvdtools
      seclists
      git-crypt
      gpgme
      gpg-tui
      oath-toolkit
    ];
    config.nixosCliPackages.security = with pkgs; [
    ];

    ################################################################################
    #
    # supervisors
    #
    config.sharedCliPackages.supervisors = with pkgs; [
      ## supervisors / runners
      overmind
      watch
      watchman
      watcher
      watchexec
      fswatch
    ];
    config.nixosCliPackages.supervisors = with pkgs; [
    ];

    ################################################################################
    #
    # display
    #
    config.sharedCliPackages.display = with pkgs; [
      ## text readers, pagers
      # fltrdr
      nvimpager
      less
      most
      moar
      viddy
      ov

      ## graphing
      d2
      graphviz
      mermaid-cli
      structurizr-cli

      ## image / graphics / multimedia
      pastel
      chafa
      ueberzugpp
      viu
      ghostscript
      latex2html

      ## fonts
      nerd-font-patcher
      fontconfig

      ## highlighting
      chroma
    ];
    config.nixosCliPackages.display = with pkgs; [
    ];

    ################################################################################
    #
    # filetypes: cli packages for handling specific file formats
    #
    config.sharedCliPackages.filetypes = with pkgs; [
      ## markdown
      # markdownlint-cli
      # markdownlint-cli2
      # markdown-oxide
      # marksman

      ## markdown
      # frogmouth
      glow
      # marked-man
      # md-tui

      ## CSV
      # tidy-viewer

      ## JSON / YAML
      otree # text object tree viewer
      jq
      jqp # jq tui playground
      yq-go # jq for yaml
      jc
    ];

    config.nixosCliPackages.filetypes = with pkgs; [
      csv-tui
      ## PDF
      tdf
      ### text utils
      cicero-tui # unicode
      gtt

      ## text readers, pagers
      fltrdr
      circumflex
    ];

    ################################################################################
    #
    # www
    #
    config.sharedCliPackages.www = with pkgs; [
      ## www
      w3m-full
      browsh
      lynx
    ];
    config.nixosCliPackages.www = with pkgs; [
    ];

    ################################################################################
    #
    # frivolity
    #
    config.sharedCliPackages.frivolity = with pkgs; [
      figlet
    ];
    config.nixosCliPackages.frivolity = with pkgs; [
      ## frivolity
      neofetch
      fastfetch
      fortune
      cmatrix
      nms
    ];
  };

  #
  # import these to pull in all cli packages for a platform
  # or, just import cliPackages and cherry-pick
  #
  flake.darwinModules.cliPackages = {
    self,
    config,
    ...
  }: {
    imports = [self.flakeModules.cliPackages];
    environment.systemPackages = collectSharedPackages config;
  };

  flake.nixosModules.cliPackages = {
    self,
    config,
    ...
  }: {
    imports = [self.flakeModules.cliPackages];
    environment.systemPackages = collectNixosPackages config ++ collectSharedPackages config;
  };
}
