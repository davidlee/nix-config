
{ 
  pkgs,
  inputs,
  ...
}: {

  environment.systemPackages = with pkgs; [

    ## daw & audio
    carla
    reaper
    bitwig-studio      
    renoise
    lmms 
    zrythm
    ardour
    hydrogen
    audacity
    yoshimi
    qtractor
    rakarrack
    guitarix
    supercollider-with-plugins
    chuck
    vcv-rack
    
    ## graphics & 3d
    blender
    gimp-with-plugins
    krita
    inkscape
    darktable
    ansel
    digikam
    penpot-desktop
    pikopixel

    ## media players
    vlc
    kodi-wayland
    # kodi-cli
    celluloid
    mpv
    kdePackages.gwenview

    ## video
    shotcut
    
    ## util
    _1password-gui      
    virt-viewer 
    upscayl
    evince
    persepolis
    qbittorrent
    calibre
    flameshot
    ventoy-full
    artha
    guvcview
    inxi
    easyeffects
    barrier

    ## productivity
    thunderbird-latest
    evolution
    # morgen # TODO enable when electron deps fixed
    zotero
    foliate
    onlyoffice-bin
    libreoffice
    gnome-frog
    papers
    scribus

    ## games
    retroarch-full
    limo    
    lutris
    gamehub

    ## messaging / social
    newsflash
    discord
    beeper
    signal-desktop
    slack
    zoom-us
    rambox
    telegram-desktop
    element-desktop

    ## music player & library management
    beets
    fooyin
    quodlibet
    spotify
    tauon
    tokei
    deadbeef
    cantata
    
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

    ## search
    recoll
    
    ## 

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
    qutebrowser
    floorp
    ungoogled-chromium
    palemoon-bin
    tor-browser
    wavebox
    kdePackages.angelfish
    # midori
    
    ## non-web
    bombadillo
    amfora

    ## gamedev
    godot
  ];
}
