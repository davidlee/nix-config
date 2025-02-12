{...}: {
  security.rtkit.enable = true;
  security.polkit.enable = true;

  # FIXME insecure, but convenient. Get a yubikey instead.
  security.sudo.wheelNeedsPassword = false;

  security.pam.services.hyprlock = {};
  security.pam.services.swaylock = {};
}
