# Sleipnir's feature selection: the profiles it imports, the features it
# selects itself, and the legacy flags it overrides (defaults in
# ../../modules/features.nix). Anything not named here takes the default.
{
  imports = [../../features/profiles/workstation.nix];

  # A property of this host, not a profile: capsule needs KVM and the local
  # oubliette checkout.
  feature.virt.capsule.enable = true;
  # Also a host property: qemu needs KVM (DEC-021).
  feature.virt.qemu.enable = true;

  # Host properties too: this is the gaming machine.
  feature.games = {
    steam.enable = true;
    gamescope.enable = true;
    mangohud.enable = true;
  };

  desktop = {
    sway = true;
    niri = true;
    cosmic = true;
    kde = true;
    mango = true;
  };

  ai = {
    llama-cpp = false;
    rocm = false;
  };
  apps.cad = true;
  fonts = true;
  printing = true;
  speech = false;
  mpd = true;
  sunshine = false;
  webserver = true;
}
