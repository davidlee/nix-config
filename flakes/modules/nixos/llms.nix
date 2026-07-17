{
  inputs,
  pkgs,
  ...
}: {
  environment.systemPackages = [pkgs.claude-desktop];
  nixpkgs.overlays = [inputs.claude-desktop.overlays.default];
}
