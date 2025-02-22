{
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    # inputs.nix-inspect.packages.${pkgs.system}.default
    # inputs.hyprland.packages.${pkgs.system}.default
    smem
    btrfs-progs
    hdparm
    smartmontools
    usbutils # lsusb
    greetd.greetd
    btop
    nix-inspect
    nix-tree
    sysstat
    tcpdump
    iptraf-ng
    iotop
    iftop
    nethogs
    nmon
    vnstat
    htop
    atop
    strace
    gtop
    pydf
    dig
    pinfo
    greetd.tuigreet
    # nix-linter
    nix-du
    nix-melt
    nix-top
    nix-diff
    nix-bisect
    nix-btm
    cachix
    directx-headers
    directx-shader-compiler
    _7zz
    alsa-utils
    # amdvlk
    appimage-run
    autoconf
    # bash-language-server
    # bat
    bat
    binutils
    bison
    bottom
    broot
    btop
    cachix
    clang
    cmake
    dwl
    # cmatrix
    # cowsay
    cpio
    dconf
    # dconf2nix
    # dconf-editor
    direnv
    # duf
    duf
    # efibootmgr
    emacs
    # eza
    eza
    fd
    ffmpeg
    file
    # file-roller
    findutils
    # fwupd
    fzf-zsh
    fzy
    gawk
    gcc
    # gccgo14
    gh
    # gimp
    # git
    git
    gitu
    glfw
    gnumake
    gnused
    # gomuks
    # greetd.tuigreet
    # htop
    htop
    i3status
    ictree
    imv
    # inxi
    # jq
    just
    keepassxc
    killall
    # lazygit
    libGL
    libnotify
    # libvirt
    # linuxKernel.packages.linux_zen.cpupower
    # lldb
    llvm
    # lm_sensors
    # lolcat
    lsd
    lshw
    # lxqt.lxqt-policykit
    mesa
    meson
    mods
    mpv
    # ncdu
    ncdu
    xplr
    #neovide
    # nh
    # nil
    ninja
    nmap
    nnn
    # nodejs_22
    # nodePackages.prettier
    # nvtopPackages.amd
    # olm
    ols
    openssl
    pciutils
    # pfetch-rs
    phinger-cursors
    pipewire
    pipx
    pkg-config
    plocate
    # pokemon-colorscripts-mac
    polkit
    # prettierd
    # profile-sync-daemon
    pstree
    python312
    python312Packages.pywatchman
    # ripgrep
    ripgrep
    # rose-pine-cursor
    ruby
    # ruff
    # rustc
    rustup

    # sway
    tmux
    # tradingview
    # tree
    tree
    # unipicker
    unrar
    unzip
    # v4l-utils
    valgrind
    # vim
    wget
    which
    xdg-desktop-portal-hyprland
    xfce.thunar
    zls
    zsh
    zstd

  ];
}
