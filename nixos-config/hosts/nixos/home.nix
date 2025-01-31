{ config, pkgs, username, ... }: {

  # Home Manager Settings
  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";
    stateVersion = "24.11";
  };

  imports = [
    # ../../config/ *
    # ../../modules/homeManagerModules/ *
  ];
  
  home.packages = with pkgs;
    [
      # hyprland
      # hyprlandPlugins.hyprscroller
    ];

  home.file = {
    # ...
  };
  
  # Nicely reload system units when changing configs
  # systemd.user.startServices = "sd-switch";

}
