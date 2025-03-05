{ pkgs, ...}: {

  environment.systemPackages = with pkgs; [
    git
    zsh
  ];

  # environment.variables.EDITOR = "hx";

}
