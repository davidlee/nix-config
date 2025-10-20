{
  description = "A rust flake-parts shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };
  outputs = inputs @ {
    flake-parts,
    rust-overlay,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-darwin" "x86_64-darwin"];
      perSystem = {
        #config,
        #self',
        #inputs',
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

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            rust-bin.beta.latest.default
            # rust-bin.selectLatestNightlyWith
            # (toolchain: toolchain.default)
          ];
        };

        # devShells.default = pkgs.mkShell {
        #   nativeBuildInputs = with pkgs; [
        #     rust-bin.selectLatestNightlyWith
        #     (toolchain: toolchain.default)
        #   ];
        # };
      };
    };
}
