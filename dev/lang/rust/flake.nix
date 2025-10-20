{
  description = "A rust flake-parts shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-parts.url = "github:hercules-ci/flake-parts";
    devshell.url = "github:numtide/devshell";
  };

  outputs = inputs @ {
    flake-parts,
    rust-overlay,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [inputs.devshell.flakeModule];

      perSystem = {
        pkgs,
        system,
        ...
      }: {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system rust-overlay;
          overlays = [
            rust-overlay.overlays.default
          ];
        };

        devshells.default = {
          packages = with pkgs; [
            (rust-bin.selectLatestNightlyWith (toolchain: toolchain.default))
          ];
        };
      };
    };
}
