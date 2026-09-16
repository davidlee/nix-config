# Coarse-grained feature toggles for this host.
#
# A plain attrset, not a NixOS module: the NixOS and home-manager configs are
# evaluated independently (separate nixpkgs, separate `switch`), so an option
# declared in one is invisible to the other. flake.nix threads this through
# both `specialArgs` and `extraSpecialArgs` instead, giving one edit point.
{
  games = false;
}
