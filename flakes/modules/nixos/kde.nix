{...}: {
  flake.nixosModules.kde = {pkgs, ...}: {
    services = {
      xserver.enable = true;

      displayManager.sddm = {
        enable = true;
        wayland.enable = true;
        settings.General.DisplayServer = "wayland";
      };

      desktopManager.plasma6.enable = true;
    };

    programs.ssh.askPassword = pkgs.lib.mkForce "${pkgs.kdePackages.ksshaskpass.out}/bin/ksshaskpass";

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

      # kiconthemes
      # kscreenlocker
      kwindowsystem
      # kaccounts-providers

      kde-cli-tools
      # calendarsupport
      bluedevil
      bluez-qt
      # xwaylandvideobridge

      dolphin
      dolphin-plugins
      # drkonqi

      # kate
      # kweather
      # gwenview
      # karchive
      # marknote
    ];

    # environment.plasma6.excludePackages = with pkgs.kdePackages; [
    #   plasma-browser-integration
    # ];
  };
}
