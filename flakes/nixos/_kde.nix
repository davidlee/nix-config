{pkgs, ...}: {
  services = {
    xserver.enable = true;

    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      settings.General.DisplayServer = "wayland";
    };

    desktopManager.plasma6.enable = true;
  };

  environment.systemPackages = with pkgs.kdePackages; [
    kate
    kdeplasma-addons
    wayland
    kmouth
    # kamoso
    ksshaskpass
    calendarsupport
    kaccounts-providers
    kpkpass
    kdesu
    kwrited
    kweather
    kalarm
    kalk
    kalm
    kasts
    kauth
    kbookmarks
    ark
    bluedevil
    bluez-qt
    breeze
    breeze-icons
    breeze-gtk
    breeze-plymouth
    calligra
    cantor
    dolphin
    dolphin-plugins
    drkonqi
    elisa
    eventviews
    falkon
    filelight
    ghostwriter
    gwenview
    isoimagewriter
    # kapidox BROKEN
    karchive
    katomic
    kbackup
    kbookmarks
    kaddressbook
    kcachegrind
    kcolorchooser
    kcolorpicker
    kcron
    kde-cli-tools
    kdiagram
    kget
    kgeography
    kgamma
    kgraphviewer
    kiconthemes
    klevernotes
    kmix
    koi
    kolf
    konqueror
    konversation
    korganizer
    kruler
    kscreen
    kscreenlocker
    ktimer
    # ktouch
    ktorrent
    kwallet-pam
    kwalletmanager
    kwave
    kwin
    kwindowsystem
    marknote
    # neochat
    plasma-desktop
    plasma-systemmonitor
    plasma-browser-integration
    plasma-thunderbolt
    plasma-vault
    plasma-workspace
    plasma-workspace-wallpapers
    plasmatube
    spectacle
    xwaylandvideobridge
    zanshin
  ];

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    plasma-browser-integration
  ];
}
