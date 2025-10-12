({
  inputs,
  system,
  # pkgs,
  ...
}: {
  nixpkgs.overlays = [inputs.nur.overlays.default];

  # Helium browser
  environment.systemPackages = [
    inputs.nur.legacyPackages."${system}".repos.Ev357.helium
  ];

  # let
  #   nightly = (pkgs.rust-bin.selectLatestNightlyWith(
  #     toolchain: toolchain.default.override {
  #       extensions = [ "rust-analyzer" "rustfmt" "clippy" "rustc-dev" "rust-src" ];
  #     }));
  # in [ nightly ];
})
