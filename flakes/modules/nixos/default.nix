# The NixOS base: what every NixOS host imports (DEC-027, DEC-042, DEC-044).
# Not a feature and not a profile: it has no switch. Optional pieces are
# features (../../features), machine- and host-bound pieces live in
# hosts/<host>/.
{
  imports = [
    ./boot.nix
    ./env.nix
    ./kernel.nix
    ./maintenance.nix
    ./network.nix
    ./nix.nix
    ./programs.nix
    ./security.nix
    ./user.nix
    ./cli.nix
  ];
}
