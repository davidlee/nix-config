{
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    # inputs.nix-inspect.packages.${pkgs.system}.default
    nix-inspect
    nix-tree
    neofetch
    dwl
    river
    zathura
    spatial-shell
    # nix-linter
    nix-du
    nix-melt
    nix-top
    nix-diff
    nix-bisect
    nix-btm
    sd-switch
    zed-editor
    cachix
    typescript
    typescript-language-server
    vscode
    _1password-cli
    _1password-gui
    _7zz
    alacritty
    alsa-utils
    # amdvlk
    appimage-run
    aria2
    aspell
    autoconf
    # bash-language-server
    # bat
    bat
    beeper
    bibata-cursors
    binutils
    bison
    bitwarden-cli
    bitwarden-desktop
    bottom
    broot
    btop
    bun
    cachix
    caddy
    clang
    clipman
    clipse
    cmake
    # cmatrix
    copyq
    # cowsay
    cpio
    d2
    dconf
    # dconf2nix
    # dconf-editor
    delta
    difftastic
    direnv
    discord
    dmenu
    dmidecode
    dolphin
    # duf
    duf
    # efibootmgr
    emacs
    exercism
    # eza
    eza
    fd
    ffmpeg
    file
    # file-roller
    findutils
    foot
    fuzzel
    # fwupd
    fzf-zsh
    fzy
    gawk
    gcc
    # gccgo14
    gh
    ghostty
    # gimp
    # git
    git
    gitu
    glfw
    glow
    gnumake
    gnused
    go
    # gomuks
    graphviz
    # greetd.tuigreet
    grim
    helix
    hexyl
    # htop
    htop
    httpie
    # hypr
    # hyprcursor
    # hyprdim
    # hypre
    # hyprkeys
    # hyprland
    # hyprland-activewindow
    # hyprlandPlugins.hyprscroller
    # hyprlang
    # hyprlock
    # hyprls
    # hyprnome
    # hyprnotify
    # hyprpaper
    # hyprpolkitagent
    # hyprshot
    # hyprsome
    # hyprspace
    # hyprsunset
    # hyprutils
    i3status
    ictree
    imv
    # inxi
    # jq
    jq
    just
    kakoune
    keepassxc
    killall
    kitty
    # lazygit
    lazygit
    libGL
    libnotify
    # libvirt
    # linuxKernel.packages.linux_zen.cpupower
    lldb
    llvm
    # lm_sensors
    local-ai
    # lolcat
    lsd
    lshw
    lua
    lua54Packages.luarocks-nix 
    luajit
    luajitPackages.fzf-lua
    # lua-language-server
    lua-language-server
    luarocks-packages-updater
    lutris
    # lxqt.lxqt-policykit
    mako
    manix
    markdownlint-cli
    markdownlint-cli2
    marksman
    mesa
    # meson
    meson
    mods
    mpv
    # ncdu
    ncdu
    #neovide
    neovim
    neovim-gtk
    nerd-font-patcher
    # nerdfonts
    nethack
    # nh
    nh
    # nil
    nil
    ninja
    nixd
    nix-diff
    # nixfmt-rfc-style
    nix-search-cli
    nmap
    nnn
    # nodejs_22
    nodejs_23
    # nodePackages.prettier
    # nvtopPackages.amd
    nwg-look
    obsidian
    # olm
    ols
    openssl
    p7zip
    pastel
    pciutils
    # pfetch-rs
    phinger-cursors
    pipewire
    pipx
    pkg-config
    plocate
    pnpm
    # pokemon-colorscripts-mac
    polkit
    # prettierd
    # profile-sync-daemon
    pstree
    python312
    python312Packages.pywatchman
    qmk
    ranger
    rathole
    raylib
    # ripgrep
    ripgrep
    rofi-wayland
    # rose-pine-cursor
    ruby
    # ruff
    # rustc
    rustup
    semgrep
    shellcheck
    shfmt
    shotman
    signal-desktop
    slack
    slurp
    sn0int
    # socat
    #spotify
    spotify
    sqlite
    # stdenv
    stow
    # stylua
    swaybg
    swayidle
    swaylock
    syncthing
    swayr

    # sway
    tasksh
    taskwarrior3
    tldr
    tealdeer
    tmux
    tpnote
    # tradingview
    # tree
    tree
    tree-sitter
    unar
    ungoogled-chromium
    # unipicker
    unrar
    unzip
    # v4l-utils
    valgrind
    # vim
    vimPlugins.fzf-lua
    virt-viewer # graphical consol client for qemu
    vit
    viu
    vivaldi
    # vulkan-loader
    # vulkan-tools
    # vulkan-validation-layers
    watchman
    waybar
    wezterm
    # wget
    wget
    which
    wine
    wireplumber
    wl-clipboard
    wl-clipboard-rs
    wofi
    xdg-desktop-portal-hyprland
    xfce.thunar
    xh
    xwayland
    xz
    yazi
    # ydotool
    yq-go
    zellij
    zig
    # zig_0_12
    zk
    zls
    zsh
    zstd
    tealdeer
    mcfly
    tokei

  ];
}
