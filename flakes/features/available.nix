# The cli features' availability filter (DEC-036): keep the packages that
# lib.meta.availableOn accepts for pkgs' host platform and that ./cli-broken.nix
# does not list for its system. availableOn reads meta only; it cannot see a
# build that fails or a package missing from the binary cache.
#
#   available lib pkgs [ pkg … ]
lib: pkgs: let
  broken = (import ./cli-broken.nix).${pkgs.stdenv.hostPlatform.system} or [];
in
  builtins.filter (p:
    lib.meta.availableOn pkgs.stdenv.hostPlatform p
    && !(builtins.elem (lib.getName p) broken))
