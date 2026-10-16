# The NixOS base: what every NixOS host imports (DEC-027). Not a feature and
# not a profile: it has no switch. Optional pieces are features (../../features),
# machine- and host-bound pieces live in hosts/<host>/.
{
  imports = [
    ./avahi.nix
    ./boot.nix
    ./cargo.nix
    ./env.nix
    ./kernel.nix
    ./lib.nix
    ./locate.nix
    ./maintenance.nix
    ./network.nix
    ./nix.nix
    ./programs.nix
    ./security.nix
    ./ssh.nix
    ./user.nix
    ./util.nix
    ./cli.nix
  ];
}
