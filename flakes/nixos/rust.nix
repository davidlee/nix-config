({ pkgs, inputs, ... }: {
  nixpkgs.overlays = [ inputs.fenix.overlays.default ];
  environment.systemPackages = with pkgs; [
    (inputs.fenix.packages.x86_64-linux.complete.withComponents [
      "cargo"
      "clippy"
  # "rust-src"
      "rustc"
      "rustfmt"
    ])
    rust-analyzer-nightly
  ];
})
