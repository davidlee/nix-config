_: {
  flake.nixosModules.cosmic = _: {
    services = {
      desktopManager.cosmic.enable = true;
      # displayManager.cosmic-greeter.enable = true;
      # system76-scheduler.enable = true;
    };
    programs.firefox.preferences = {
      # disable libadwaita theming for Firefox
      "widget.gtk.libadwaita-colors.enabled" = false;
    };
    environment.sessionVariables = {COSMIC_DATA_CONTROL_ENABLED = 1;};
    # environment.systemPackages = with pkgs; [];
  };
}
