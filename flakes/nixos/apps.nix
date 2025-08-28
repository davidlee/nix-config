{
  pkgs,
  stable,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    ## daw & audio
    # carla # BROKEN (pyliblo)
    reaper
    bitwig-studio
    renoise
    # lmms # BROKEN
    # zrythm # BROKEN
    # ardour
    # hydrogen
    # audacity
    # yoshimi
    # qtractor
    # rakarrack
    # guitarix
    # supercollider-with-plugins
    # chuck
    vcv-rack
    cardinal
    helm
    pavucontrol

    ## graphics & 3d
    blender
    gimp-with-plugins
    krita
    inkscape
    # darktable
    # ansel
    # digikam
    penpot-desktop
    # pikopixel

    ## media players
    vlc
    # kodi-wayland
    # kodi-cli
    celluloid
    mpv
    # kdePackages.gwenview

    ## video
    # shortcut #??

    ## util
    _1password-gui
    virt-viewer
    # upscayl
    # evince
    # persepolis
    # qbittorrent
    #calibre
    flameshot
    # ventoy-full
    artha
    # guvcview
    inxi
    # easyeffects
    # barrier

    ## productivity
    thunderbird-latest
    evolution
    # morgen # TODO enable when electron deps fixed
    zotero
    foliate
    onlyoffice-bin
    libreoffice
    # gnome-frog
    papers
    scribus

    ## games
    # retroarch-full
    # limo
    # lutris
    # gamehub

    ## messaging / social
    newsflash
    #discord broken, using stable
    stable.discord
    beeper
    signal-desktop
    slack
    zoom-us
    # rambox
    telegram-desktop
    element-desktop
    whatsie

    ## music player & library management
    # beets
    # fooyin
    # quodlibet
    spotify
    # tauon
    # tokei
    # deadbeef
    # cantata

    ## terminals
    alacritty
    wezterm
    foot
    ghostty
    kitty
    rio

    ## editors
    neovim-gtk
    emacs-gtk
    obsidian
    code-cursor
    vscode
    zed-editor
    joplin
    claude-code
    zim
    kdePackages.kate
    lapce
    saber
    # sublime4
    marktext
    apostrophe

    ## mind map etc
    freemind
    minder
    semantik
    vue

    # ai / ml
    gpt-cli
    claude-code

    ## search
    recoll

    ## scanner
    # naps2
    xsane
    kdePackages.skanlite
    kdePackages.skanpage

    ## data:
    # dbvisualizer
    # beekeeper-studio

    # zim-tools
    # vscode-extensions.saoudrizwan.claude-dev
    # vscodium

    ## browsers
    inputs.zen-browser.packages.${pkgs.system}.default
    vivaldi
    ladybird
    librewolf
    firefox
    firefoxpwa
    qutebrowser
    floorp
    ungoogled-chromium
    palemoon-bin
    tor-browser
    # kdePackages.angelfish
    pkgs.firefoxpwa
    # midori

    ## non-web
    bombadillo
    amfora

    ## gamedev
    # godot
    # stable.godot_4
  ];

  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
    nativeMessagingHosts.packages = [pkgs.firefoxpwa];
  };
}
