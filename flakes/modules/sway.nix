{
  config,
  pkgs,
  username,
  lib,
  ...
}:
let
  mod = "Mod4";
in {

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
      ulauncher
      wshowkeys
      kanshi
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

    # https://github.com/nix-community/home-manager/blob/master/modules/services/window-managers/i3-sway/sway.nix

    wayland.windowManager.sway = {
      enable = true;
      config = {
        modifier = mod;
        terminal = "kitty";
        workspaceAutoBackAndForth = true;

        gaps = {
          smartGaps = true;
          smartBorders = "on";
          outer = 5;
          inner = 15;
        };

        keybindings = lib.attrsets.mergeAttrsList [
        (lib.attrsets.mergeAttrsList (map (num: let
          ws = toString num;
        in {
          "${mod}+${ws}" = "workspace ${ws}";
          "${mod}+Ctrl+${ws}" = "move container to workspace ${ws}";
        }) [1 2 3 4 5 6 7 8 9]))

        (lib.attrsets.concatMapAttrs (key: direction: {
            "${mod}+${key}" = "focus ${direction}";
            "${mod}+Shift+${key}" = "move ${direction}";
          }) {
            left  = "left";
            down  = "down";
            up    = "up";
            right = "right";
          })

          {
            "${mod}+Return" = "exec --no-startup-id ${pkgs.kitty}/bin/kitty";
            "Alt+space" = "exec --no-startup-id wofi --show drun,run";
            "Alt+Tab" = "exec swayr switch-window";

            "${mod}+k" = "kill";

            "${mod}+a" = "focus parent";
            "${mod}+f" = "fullscreen toggle";
            "${mod}+g" = "split h";
            "${mod}+v" = "split v";
            "${mod}+e" = "layout toggle split";
            "${mod}+s" = "layout stacking";
            "${mod}+w" = "layout tabbed";
            "${mod}+space" = "exec fuzzel";
            "${mod}+n" = "scratchpad show";
            "${mod}+Shift+n" = "move scratchpad";
          
            # replace floating window binds we stomped with launcher binds on space
            "${mod}+l" = "focus mode_toggle";
            "${mod}+Shift+l" = "floating toggle";

            "${mod}+Shift+r" = "exec swaymsg reload";
            "${mod}+z" = "exec --no-startup-id ${pkgs.sway-contrib.grimshot}/bin/grimshot copy area";
            "${mod}+Ctrl+l" = "exec ${pkgs.swaylock-fancy}/bin/swaylock-fancy";
            "${mod}+Ctrl+q" = "exit";
          }
        ];
        startup = [
          # { command = "firefox"; }
          {
            command = "systemctl --user restart kanshi";
            always = true;
          }
          {
            command = "systemctl --user restart waybar";
            always = true;
          }
          {
            command = "systemctl --user restart swayidle";
            always = true;
          }
          {
            command = "systemctl --user restart swayr";
            always = true;
          }
        ];

        bars = [];
        floating.titlebar = false;
        window.titlebar = false;
      };
      # swaynag.enable = false;
      wrapperFeatures.gtk = true;
      extraOptions = [ "--unsupported-gpu" ];
    };
  };
  
  services = {
    blueman.enable = true;
  };

  security = {
    polkit.enable = true;
    pam.services.swaylock = {};
  };
}
