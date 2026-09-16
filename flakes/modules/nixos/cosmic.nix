_: {
  services = {
    desktopManager.cosmic.enable = true;
  };

  programs.firefox.preferences = {
    # disable libadwaita theming for Firefox
    "widget.gtk.libadwaita-colors.enabled" = false;
  };
  environment.sessionVariables = {COSMIC_DATA_CONTROL_ENABLED = 1;};
}
