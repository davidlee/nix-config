{ username, inputs, ... }: {

  imports = [
    inputs.walker.homeManagerModules.default
    ../../home/zsh.nix
    ../../home/kitty.nix
   ];
  
  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";
    stateVersion = "24.11";
    sessionVariables = {
      EDITOR = "hx";
      DIFFPROG = "delta";
      MANPAGER = "nvim +Man!";

      XCURSOR_SIZE = 24;
      NIXOS_OZONE_WL = 1;
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  programs.home-manager.enable = true;
 }
