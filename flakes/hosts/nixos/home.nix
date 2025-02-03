{ config, pkgs, username, inputs, ... }: {

  # Home Manager Settings
  home = {
    username = "${username}";
    # homeDirectory = "/home/${username}";
    stateVersion = "24.11";
  };

  imports = [
    inputs.walker.homeManagerModules.default
    ../../nixos/home/packages.nix
    ../../nixos/home/programs.nix
    ../../nixos/home/hyprland.nix
    
   ];

  services.swayidle.enable = true;

  # inputs.modules = [
  #   inputs.hyprland.homeManagerModules.default
  #   {
  #     wayland.windowManager.hyprland = {
  #       enable = true;
  #       plugins = [ inputs.hy3.packages.x86_64-linux ];
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
