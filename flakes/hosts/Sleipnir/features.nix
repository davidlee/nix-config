# Sleipnir's feature selection: the profiles it imports, and the features it
# selects itself. Anything not named here is off (tree features default to
# false).
{
  imports = [
    ../../features/profiles/workstation.nix
    ../../features/profiles/personal-linux.nix
  ];

  # A property of this host, not a profile: capsule needs KVM and the fleet
  # checkout at /srv/fleet.
  feature.virt.capsule.enable = true;
  # Also a host property: qemu needs KVM (DEC-021).
  feature.virt.qemu.enable = true;

  # Host properties too: this is the gaming machine.
  feature.games = {
    steam.enable = true;
    gamescope.enable = true;
    mangohud.enable = true;
  };

  # Peripherals are host properties (DEC-011, DEC-021).
  feature.hardware = {
    bluetooth.enable = true;
    qmk.enable = true;
    tablet.enable = true;
    logitech.enable = true;
  };

  feature.audio = {
    mpd.enable = true; # /media/music
    # This machine's speakers and Spotify Connect name (ALARM.md).
    alarm.enable = true;
    speech.enable = true;
  };
  # printers: site-bound (IMP-017)
  feature.services = {
    # mDNS for printer discovery; printing requires it, requires never selects (ADR-001 D4)
    avahi.enable = true;
    printing.enable = true;
    postgresql.enable = true;
    webserver.enable = true;
  };

  # Taste and per-machine use (DEC-024). personal-linux also defaults spotify
  # and postgresql.
  feature.media = {
    spotify.enable = true;
    obs.enable = true;
  };
  feature.graphics = {
    paint.enable = true;
    modelling.enable = true;
    cad.enable = true;
  };
  feature.editor = {
    zed.enable = true;
    lem.enable = true;
  };
  feature.notes.joplin.enable = true;
  feature.ai.claude-desktop.enable = true;
  # Off while llm-agents' chatgpt fails to build (ISS-016); personal-linux selects it.
  feature.agents.chatgpt.enable = false;

  feature.desktop.greeter.enable = true; # the login screen; default session in config.nix
  feature.shell = {
    noctalia.enable = true;
    walker.enable = true;
  };

  # Taste, toggled often (DEC-024): every compositor installed.
  feature.compositor = {
    sway.enable = true;
    niri.enable = true;
    cosmic.enable = true;
    kde.enable = true;
    mango.enable = true;
    umbriel.enable = true;
  };
}
