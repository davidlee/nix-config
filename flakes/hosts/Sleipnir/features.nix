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

  feature.audio.mpd.enable = true; # /media/music
  # printers: site-bound (IMP-017)
  feature.services = {
    printing.enable = true;
    webserver.enable = true;
  };
  feature.apps.cad.enable = true; # not in a profile until IMP-016

  desktop = {
    sway = true;
    niri = true;
    cosmic = true;
    kde = true;
    mango = true;
  };

  fonts = true;
}
