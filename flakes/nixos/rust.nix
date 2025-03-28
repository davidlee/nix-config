({ inputs, pkgs, ... }: {
  nixpkgs.overlays = [ inputs.rust-overlay.overlays.default ];
  
  environment.systemPackages =
  let
    nightly = (pkgs.rust-bin.selectLatestNightlyWith(
      toolchain: toolchain.default.override {
        extensions = [ "rust-analyzer" "rustfmt" "clippy" "rustc-dev" "rust-src" ];
      }));
    # stable = (pkgs.rust-bin.stable.latest.default.override { extensions = [ "rust-analyzer" ]; });
  in [ nightly ];
})
