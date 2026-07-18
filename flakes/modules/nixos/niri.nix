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

  programs.firefox.preferences = {
    # disable libadwaita theming for Firefox
    # "widget.gtk.libadwaita-colors.enabled" = false;
  };
}
