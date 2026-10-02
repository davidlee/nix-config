{
  inputs,
  pkgs,
  username,
  hostname,
  ...
}: let
  specialArgs = {
    inherit
      inputs
      pkgs
      username
      hostname
      ;
  };
in {
  imports = [
    ./system.nix
    ./nix-core.nix
    ./brew.nix
    ./packages.nix

    inputs.home-manager.darwinModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = specialArgs;
      home-manager.backupFileExtension = "backup";
      home-manager.users.${username} = import ./home.nix;
    }
  ];

  # Pinned off lix for now: building it from source fails after the macOS 27 /
  # Xcode CLT 27 upgrade (fresh `ld64-956.6` rejects the GNU-style
  # `-z,noexecstack` flag lix's meson build passes it — "Compiler clang++
  # cannot compile programs"), and cache.lix.systems (configured in
  # nix-core.nix) has no aarch64-darwin substitute for this version yet,
  # presumably hitting the same ld64 break on their builder. Matches a known
  # upstream issue: tpoechtrager/cctools-port#193 (closed via
  # conda-forge/cctools-and-ld64-feedstock#112) — ld64 956.6 mis-parsing the
  # Xcode 27 SDK. Re-enable once a substitute appears (or building locally
  # succeeds again):
  #   nix.package = pkgs.lixPackageSets.stable.lix;
}
