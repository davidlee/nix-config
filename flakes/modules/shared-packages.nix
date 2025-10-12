{pkgs, ...}: {
  # system packages
  #
  environment.systemPackages = with pkgs; [
    ## servers
    caddy
    sqlite
    # postgresql
  ];
}
