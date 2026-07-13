{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    cargo
    cargo-update
  ];
}
