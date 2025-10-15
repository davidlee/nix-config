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
    kdeplasma-addons
    plasma-desktop
    plasma-systemmonitor
    plasma-browser-integration
    plasma-thunderbolt
    plasma-vault
    plasma-workspace
    plasma-workspace-wallpapers

    breeze
    breeze-icons
    breeze-gtk
    breeze-plymouth

    ksshaskpass
    kpkpass
    kauth
    kwallet-pam
    kwalletmanager

    kiconthemes
    kscreenlocker
    kwindowsystem
    kaccounts-providers

    kde-cli-tools
    calendarsupport
    bluedevil
    bluez-qt
    xwaylandvideobridge

    dolphin
    dolphin-plugins
    drkonqi

    kate
    kweather
    gwenview
    karchive
    marknote
    klevernotes
    zanshin

    # elisa
    # kwrited

    # kalarm
    # kdesu
    # kalk
    # kalm
    # kasts
    # kbookmarks
    # kmouth
    # kamoso
    # ark
    # calligra
    # cantor
    # eventviews
    # falkon
    # filelight
    # ghostwriter
    # isoimagewriter
    # kapidox BROKEN
    # katomic
    # kbackup
    # kbookmarks
    # kaddressbook
    # kcachegrind
    # kcolorchooser
    # kcolorpicker
    # kcron
    # kdiagram
    # kget
    # kgeography
    # kgamma
    # kgraphviewer
    # kmix
    # koi
    # kolf
    # konqueror
    # konversation
    # korganizer
    # kruler
    # kscreen
    # ktimer
    # ktouch
    # ktorrent
    # kwave
    # kwin
    # neochat
    # plasmatube
    # spectacle
  ];

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    plasma-browser-integration
  ];
}
