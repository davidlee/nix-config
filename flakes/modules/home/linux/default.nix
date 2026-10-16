# The Linux home layer: the home base (../.) plus what every Linux home
# needs. A Linux host's home.nix imports this directory; the darwin
# counterpart is ../darwin. No temporary modules remain.
{config, ...}: {
  imports = [
    ../.

    # ./helix.nix

    # parked — its flake input is commented out in ../../../flake.nix
    # ./danksearch.nix
  ];

  # GUI apps launched by the compositor never source a shell profile
  systemd.user.sessionVariables = config.home.sessionVariables;
}
