{
  pkgs,
  username,
  ...
}: {
  # Root and default-shell users get NixOS's bash (DEC-042).
  users.mutableUsers = true; # can do without password being clobbered
  users.users = {
    "${username}" = {
      homeMode = "755";
      isNormalUser = true;
      description = "David Lee";
      extraGroups = ["networkmanager" "wheel"];
      home = "/home/${username}";
      #shell = pkgs.zsh;
      shell = pkgs.zsh;
      packages = [
        pkgs.home-manager
      ];
    };
  };
}
