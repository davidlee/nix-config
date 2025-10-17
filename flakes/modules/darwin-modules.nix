{lib, ...}: {
  options.flake = {
    darwinModules = lib.mkOption {
      type = lib.types.attrsOf lib.types.raw;
      default = {};
      description = "nix-darwin modules exported by this flake.";
    };
  };
}
