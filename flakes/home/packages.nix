{ 
  pkgs,
  inputs,
  # nixpkgs-stable,
  # host,
  # username,
  ...
}: {

  # home.packages = with inputs.nixpkgs-stable; [
  #   harlequin
  # ];
  
  home.packages = with pkgs; [
    tty-clock
    clock-rs
    unixtools.nettools
    unixtools.xxd
    inetutils
    quodlibet
    tauon
    beets
    cmus
    fooyin
    nh
    nixd
    kmonad
    gdm
    protontricks
    winetricks
    wine-wayland
    winePackages.full
    gamehub
    tuba
    signal-desktop
    limo    

    # gnome-shell
    # gnome-logs
    # gnome-usage
    # gnome-panel
    # gnome-notes
    # gnome-menus
    # gnome-feeds
    # gnome-chess
    # gnome-tweaks
    # gnome-robots
    # gnome-graphs
    # gnome-common
    # gnome-weather
    # gnome-session
    # gnome-secrets
    # gnome-keysign
    # gnome-keyring
    # gnome-desktop
    # gnome-builder
    # gnome-applets
    # gnome-podcasts
    # gnome-firmware
    # gnome-contacts
    # gnome-calendar
    # gnome-gnome-user-docs
    # gnome-commander
    # gnome-doc-utils
    # gnome-bluetooth
    # gnome-screenshot
    # gnome-solanum
    # gnome-icon-theme
    # gnome-characters
    # gnome-text-editor
    # gnome-session-ctl
    # gnome-font-viewer
    # gnome-connections
    # gnome-disk-utility
    # gnome-power-manager
    # gnome-system-monitor
    # gnome-control-center
    # gnome-shell-extensions
    # gnome-settings-daemon
    # gnome-extension-manager
    # gnome-browser-connector
    # gnome-nettool
    


   
    code-cursor
    waypipe
    sway-contrib.grimshot
    swaymux
    showmethekey
    wev
    kanshi
    wmenu
    wldash
    swayimg
    swaybg
    imv
    nix-index
    gammastep
    stress-ng
    gperf
    dtc
    ccache
    devcontainer
    python313Packages.pip
    virtualenv
    dfu-util
    qemu
    # python-pip python-setuptools python-wheel
    # tk-9_0
    kitty
    hyprland
    hypr
    hyprcursor
    hyprdim
    hypre
    hyprkeys
    hyprland
    hyprland-activewindow
    # hyprlandPlugins.hyprscroller
    hyprlang
    hyprlock
    hyprls
    hyprnome
    hyprnotify
    hyprpaper
    hyprpolkitagent
    hyprshot
    hyprsome
    hyprspace
    hyprsunset
    hyprutils
    imv
    rootbar
    shotman
    sirula

    kando
    superfile
    flatpak
    gh-dash
    lazydocker
    docker
    # posting
    trippy
    # bagels
    dwlb
    somebar
    oha
    cloudlens
    # harlequin
    neofetch
    blender
    dwl
    river
    zathura
    spatial-shell
    flameshot
    nemo
    glances
    sd-switch
    zed-editor
    typescript
    typescript-language-server
    vscode
    _1password-cli
    _1password-gui
    alacritty
    aria2
    aspell
    beeper
    bibata-cursors
    # bitwarden-cli
    # bitwarden-desktop
    jujutsu
    caddy
    clipman
    clipse
    copyq
    d2
    delta
    difftastic
    discord
    dmenu
    dmidecode
    dolphin
    exercism
    foot
    fuzzel
    ghostty
    glow
    go
    graphviz
    grim
    helix
    hexyl
    httpie
    jq
    kakoune
    lazygit
    local-ai
    lua
    lua54Packages.luarocks-nix 
    # luajit
    # luajitPackages.fzf-lua
    # lua-language-server
    lua-language-server
    luarocks-packages-updater
    lutris
    mako
    manix
    markdownlint-cli
    markdownlint-cli2
    marksman
    # neovim
    # neovim-gtk
    nerd-font-patcher
    # nerdfonts
    nethack
    nh
    nil
    nixd
    nix-diff
    # nixfmt-rfc-style
    nix-search-cli
    nodejs_23
    nwg-look
    obsidian
    p7zip
    pastel
    pnpm
    qmk
    ranger
    rathole
    raylib
    rofi-wayland
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
    # stow
    # stylua
    swaybg
    # sway-unwrapped
    swww
    wbg
    wev
    wldash
    wlroots
    wob
    wtype
    xdg-desktop-portal-wlr
    swayidle
    swaylock
    syncthing
    steamcmd
    steam-tui
    gamescope
    swayr
    tasksh
    taskwarrior3
    # tldr
    tealdeer
    tpnote
    tree-sitter
    unar
    ungoogled-chromium
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
    wine
    wireplumber
    # wl-clipboard
    wl-clipboard-rs
    wofi
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
    tealdeer
    mcfly
    tokei
  ];
}
