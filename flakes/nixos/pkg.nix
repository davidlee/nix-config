{
  inputs,
  pkgs,
  username,
  ...
}: {
  environment.systemPackages = with pkgs; [
    inputs.nix-search-tv.packages.x86_64-linux.default

    # ## package management
    appimage-run
    devcontainer
    flatpak
    nix-janitor
    sd-switch
  ];
}
