# Sleipnir's feature selection: the profiles it imports, and the features it
# selects itself. Anything not named here is off (tree features default to
# false).
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

  # Taste, toggled often (DEC-024): every compositor installed.
  feature.desktop = {
    sway.enable = true;
    niri.enable = true;
    cosmic.enable = true;
    kde.enable = true;
    mango.enable = true;
  };
}
