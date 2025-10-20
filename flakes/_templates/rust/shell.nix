{
  pkgs ?
    import <nixpkgs> {
      config = {};
      overlays = [
        (import (
          builtins.fetchTarball "https://github.com/oxalica/rust-overlay/archive/master.tar.gz"
        ))
      ];
    },
}:
pkgs.mkShell {
  packages = with pkgs; [
    rust-bin.beta.latest.default
  ];
}
