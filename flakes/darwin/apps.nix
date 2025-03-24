{ pkgs, ...}: {
  # imports = [
  #   ../../../home/zsh.nix
  #   ../../../home/kitty.nix
  #  ];

  environment.systemPackages = with pkgs; [
    git
    zsh
  ];
}
