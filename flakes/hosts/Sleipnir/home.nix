{ username, inputs, ... }: {

  imports = [
    inputs.walker.homeManagerModules.default

    ../../home/apps.nix
   ];
  
  home = {
    username = "${username}";
    stateVersion = "24.11";
    sessionVariables = {
      EDITOR = "hx";
      DIFFPROG = "delta";
      MANPAGER = "nvim +Man!";

      XCURSOR_SIZE = 24;
      NIXOS_OZONE_WL = 1;
    };
  };

  # services.swayidle.enable = true;
  services.copyq.enable = true;
  
  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
