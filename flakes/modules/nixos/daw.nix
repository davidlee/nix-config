_: {
  flake.nixosModules.daw = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      bitwig-studio
      haskellPackages.tidal
      supercollider-with-plugins
      supercollider-with-sc3-plugins
      ghc

    ];
  };
}
