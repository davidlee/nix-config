{
  config,
  pkgs,
  username,
  lib,
  ...
}: {

  imports = [
    # ../home/wayland.nix
  ];

  home-manager.users.${username} = {
    home.packages = with pkgs; [
      swaybg
      sway-contrib.grimshot
      swayidle
      swayimg
      swaylock
      swaymux
      swayr
      grim
      mako
      slurp
      wl-clipboard-rs
    ];
    
    programs = {
      walker = {
        enable = true;
        runAsService = true;
      };
      waybar =  {
        enable = true;
        systemd.enable = true; 
      };
    };

    wayland.windowManager.sway = {
      enable = true;
      config = {
        modifier = "Mod4";
        terminal = "kitty";
        gaps = {
          smartGaps = true;
          smartBorders = "on";
          outer = 5;
          inner = 15;
        };

        # bars = [{
        #   command = "waybar";
        # }];

        # TODO maybe we want to use lib.attrsets.mergeAttrsList like in https://lafreniere.xyz/docs/nix-home-manager-sway.html
        keybindings =
        let
          mod = "Mod4";
        in lib.mkOptionDefault { # override not replace defaults
          "${mod}+n" = "scratchpad show";
          "${mod}+Shift+n" = "move scratchpad";
          "${mod}+t" = "layout tabbed";
          "${mod}+space" = "exec fuzzel";
        
          # replace floating window binds we stomped with launcher binds on space
          "${mod}+l" = "focus mode_toggle";
          "${mod}+Shift+l" = "floating toggle";
        };
      };
      # swaynag.enable = false;
      extraOptions = [ "--unsupported-gpu" ];
    };

  };
  security.polkit.enable = true;
  security.pam.services.swaylock = {};

  ## TODO swaybar
}
