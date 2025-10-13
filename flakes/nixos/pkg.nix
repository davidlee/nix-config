{
  inputs,
  pkgs,
  username,
  ...
}: {
  environment.systemPackages = with pkgs; [
    inputs.nix-search-tv.packages.x86_64-linux.default

    # ## https://jade.fyi/blog/pinning-nixos-with-npins/
    npins

    # ## package management
    appimage-run
    devcontainer
    flatpak
    nix-janitor
    sd-switch
  ];
}
