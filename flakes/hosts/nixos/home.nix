{ config, pkgs, username, hyprland, hy3, ... }: {

  # Home Manager Settings
  home = {
    username = "${username}";
    # homeDirectory = "/home/${username}";
    stateVersion = "24.11";
  };

  imports = [
    ../../nixos/home/packages.nix
    ../../nixos/home/programs.nix
    ../../nixos/home/hyprland.nix
  ];

  services.swayidle.enable = true;

  # modules = [
  #   hyprland.homeManagerModules.default
  #   {
  #     wayland.windowManager.hyprland = {
  #       enable = true;
  #       plugins = [ hy3.packages.x86_64-linux ];
  #     };
  #   }
  # ];  

  home.file = {
    # ...
  };
  
  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  home.sessionVariables = {
    EDITOR = "hx";
    DIFFPROG = "delta";
    MANPAGER = "nvim +Man!";
    ZMK_CONFIG = "";
    GITHUB_OAUTH_TOKEN = "";

    XCURSOR_SIZE = 24;
    NIXOS_OZONE_WL = 1;
  };

}
