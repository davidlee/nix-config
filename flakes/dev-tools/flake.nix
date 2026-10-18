{
  description = "nix-config's tool set, for the oubliette room's toolsPackage";

  # A subflake, not an output of ../flake.nix: the fleet that builds the room is
  # an input of that flake, so taking it back as the fleet's input would be a
  # cycle. What `just fmt`/`just gate` run, minus `nix` (the guest has its own).
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {nixpkgs, ...}: let
    systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
    forAll = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
  in {
    packages = forAll (pkgs: {
      dev-tools = pkgs.buildEnv {
        name = "nix-config-dev-tools";
        paths = with pkgs; [
          just
          jq
          nushell # features/attention/nudge/nudge-test.nu
          alejandra
          statix
          deadnix
        ];
      };
    });
  };
}
