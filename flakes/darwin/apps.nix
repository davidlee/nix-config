{ pkgs, ...}: {

  environment.systemPackages = with pkgs; [
    git
    zsh
  ];

}
