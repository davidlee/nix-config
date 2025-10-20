let
  rustball = builtins.fetchTarball "https://github.com/oxalica/rust-overlay/archive/master.tar.gz";
in
  {
    pkgs ?
      import <nixpkgs> {
        config = {};
        overlays = [(import rustball)];
      },
  }:
    pkgs.mkShell {
      packages = with pkgs; [
        rust-bin.beta.latest.default
      ];
    }
