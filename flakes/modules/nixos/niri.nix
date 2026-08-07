{
  pkgs,
  inputs,
  ...
}: {
  programs = {
    niri = {
      enable = true;
      useNautilus = true;
    };
  };

  environment.systemPackages = with pkgs; [
    xwayland-satellite
    stasis
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    cosmic-edit
    cosmic-wallpapers
  ];
  security.pam.services.swaylock = {};

  services.gvfs.enable = true; # Enables Trash, network mounts, and storage detection
  services.tumbler.enable = true; # Enables image/video thumbnails in file managers
  programs.firefox.preferences = {
    # disable libadwaita theming for Firefox
    # "widget.gtk.libadwaita-colors.enabled" = false;
  };
}
