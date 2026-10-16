# The Linux home layer: the home base (../.) plus what every Linux home
# needs. A Linux host's home.nix imports this directory; the darwin
# counterpart is ../darwin. The GUI modules below are temporary: SL-008 P3
# and P5 move them into features.
{config, ...}: {
  imports = [
    ../.

    ./ai.nix
    ./alarm.nix
    ./browsers.nix
    ./editors.nix
    ./graphics.nix
    # ./helix.nix
    ./media.nix
    ./obs-studio.nix
    ./office.nix
    ./terminals.nix
    ./wayland.nix
    ./zed-editor.nix

    # parked — its flake input is commented out in ../../../flake.nix
    # ./danksearch.nix
  ];

  # GUI apps launched by the compositor never source a shell profile
  systemd.user.sessionVariables = config.home.sessionVariables;
}
