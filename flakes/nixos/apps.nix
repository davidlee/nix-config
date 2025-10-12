{
  pkgs,
  stable,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    ## media players
    vlc
    # kodi-wayland
    # kodi-cli
    celluloid
    mpv
    # kdePackages.gwenview

    ## video
    # shortcut

    ## util
    pavucontrol
    _1password-gui
    flameshot
    # virt-viewer
    # upscayl
    # evince
    # persepolis
    # qbittorrent
    # calibre
    # ventoy-full
    # artha
    # guvcview
    # inxi
    # easyeffects
    # barrier

    ## productivity
    thunderbird-latest
    #evolution
    # morgen # TODO enable when electron deps fixed
    zotero
    #foliate
    onlyoffice-bin
    libreoffice
    # gnome-frog
    papers
    scribus

    ## messaging / social
    newsflash
    discord # broken, using stable
    #stable.discord
    beeper
    signal-desktop
    slack
    zoom-us
    # rambox
    # telegram-desktop
    element-desktop
    #whatsie

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
    #wezterm
    foot
    ghostty
    kitty
    rio

    ## mind map etc
    freemind
    # minder
    # semantik
    # vue

    ## search
    recoll

    ## scanner
    # naps2
    # xsane
    # kdePackages.skanlite
    # kdePackages.skanpage

    ## data:
    # dbvisualizer
    # beekeeper-studio

    # zim-tools
    # vscode-extensions.saoudrizwan.claude-dev
    # vscodium

    ## non-web
    # bombadillo
    # amfora

    ## gamedev
    # godot
    # stable.godot_4
  ];
  services.flatpak.enable = true;
}
