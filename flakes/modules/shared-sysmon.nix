{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    ## system monitors
    bottom
    btop
    glances
    htop
    gtop
  ];
}
