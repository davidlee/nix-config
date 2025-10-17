{inputs, ...}: {
  flake.nixosModules.user = {
    pkgs,
    username,
    ...
  }: {
    users.mutableUsers = true; # can do without password being clobbered

    users.users = {
      "${username}" = {
        homeMode = "755";
        isNormalUser = true;
        description = "David Lee";
        extraGroups = ["networkmanager" "wheel" "root" "dev" "video" "docker" "caddy" "libvirtd" "jackaudio" "audio" "gamemode" "input"];
        home = "/home/${username}";
        shell = pkgs.zsh;
        packages = [
          inputs.home-manager.packages.${pkgs.system}.default
        ];
      };
    };
  };
}
