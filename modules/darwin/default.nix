{ pkgs, ... }: {
  # here go the darwin preferences and config items
  programs.zsh.enable = true;
  users.users.davidlee.home = "/Users/davidlee";
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  imports = [
    ./settings/system.nix
    ./settings/environment.nix
    ./settings/homebrew.nix
  ];
}
