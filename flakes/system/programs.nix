{pkgs, inputs, lib, config, ...}: 
  with lib;
  # let
  #   cfg = config.myConfig;
  # in
  {  
  
    programs = {
      nix-ld.enable = true;
    
      dconf.enable = true;

      sway = {
        enable = true;
      };

    # waybar =  {
    #   enable = true;
    #   systemd.enable = true; 
    # };

  
      # hyprland = mkIf config.myConfig.hyprland.enable {
      #   enable = true; 
      #   withUWSM = true;
      #   package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      #   portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;    
      # };
      
      thunar = {
        enable = true;
        plugins = with pkgs.xfce; [thunar-archive-plugin thunar-volman];
      };

      zsh.enable = true;
    };

}
