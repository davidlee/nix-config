{
  pkgs,
  host,
  username,
  ...
}: {
  home.packages = with pkgs; [
    # inputs.hyprland-qtutils.packages."${pkgs.system}".default
    # pkgs.fzf
    # pkgs.glow # markdown previewer in terminal
    waypipe
    nix-index
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
    harlequin
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
    bitwarden-cli
    bitwarden-desktop
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
