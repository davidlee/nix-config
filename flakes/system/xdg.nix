{pkgs, ...}: {
  # Extra Portal Configuration
  # 
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
      xdg-desktop-portal-cosmic
      xdg-desktop-portal
      ];
    configPackages = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
      xdg-desktop-portal-cosmic
      xdg-desktop-portal
    ];
  };

  environment.systemPackages = with pkgs; [
    xdg-desktop-portal-gtk
    xdg-desktop-portal-wlr
    xdg-desktop-portal-cosmic
    xdg-desktop-portal
  ];
}
