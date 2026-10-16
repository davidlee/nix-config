# The Linux home layer: the home base (../.) plus what every Linux home
# needs. A Linux host's home.nix imports this directory; the darwin
# counterpart is ../darwin. The modules below are temporary: SL-008 P4 moves
# editors, graphics and office into features, P5 alarm.
{config, ...}: {
  imports = [
    ../.

    ./alarm.nix
    ./editors.nix
    ./graphics.nix
    # ./helix.nix
    ./office.nix

    # parked — its flake input is commented out in ../../../flake.nix
    # ./danksearch.nix
  ];

  # GUI apps launched by the compositor never source a shell profile
  systemd.user.sessionVariables = config.home.sessionVariables;
}
