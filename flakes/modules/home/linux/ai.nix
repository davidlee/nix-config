{
  inputs,
  pkgs,
  ...
}: {
  home.packages = [
    pkgs.claude-desktop
    #inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
