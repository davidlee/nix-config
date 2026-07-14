{
  pkgs,
  username,
  ...
}: {
  users = {
    mutableUsers = true; # can do without password being clobbered
    defaultUserShell = pkgs.zsh;
  };
  users.users = {
    "${username}" = {
      homeMode = "755";
      isNormalUser = true;
      description = "David Lee";
      extraGroups = ["networkmanager" "wheel" "dev" "video" "docker" "caddy" "libvirtd" "jackaudio" "audio" "gamemode" "input"];
      home = "/home/${username}";
      #shell = pkgs.zsh;
      shell = pkgs.nushell;
      packages = [
        pkgs.home-manager
      ];
    };
  };
}
