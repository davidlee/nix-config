{
  pkgs,
  username,
  ...
}: {
  environment.systemPackages = with pkgs; [
    # ## package management
    appimage-run
    devcontainer
    flatpak
    nix-janitor
    sd-switch
  ];
}
