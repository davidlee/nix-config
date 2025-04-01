{
  pkgs,
  username,
  lib,
  ...
}:
let
  mod = "Mod4";
  # term = "${pkgs.ghostty}/bin/ghostty";
  term = "${pkgs.kitty}/bin/kitty";
in {

 # TODO style / config for swayr + fuzzel

  security = {
    polkit.enable = true;
    pam.services.swaylock = {};
  };

  programs = {
    dconf.enable = true;
    sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };
  };



  services = {
    gnome = {
      gnome-keyring.enable = true;
    };
    
    blueman.enable = true;
    sysprof.enable = true;
  };
  
  home-manager.users.${username} = {
    home.packages = with pkgs; [
      sway-launcher-desktop
      sway-audio-idle-inhibit
      sway-easyfocus
      sway-overfocus
      sway-scratch
      sway-new-workspace
      sway-contrib.grimshot
      swaybg
      swayidle
      swayimg
      swaylock
      swaymux
      waybar
      swaycons
      swaysettings
      swayr
      swayrbar

      gdk-pixbuf
      gdk-pixbuf-xlib

      adwaita-icon-theme
      marble-shell-theme

      gnome-secrets
    ];

    programs = {
      swayr = {
        enable = true;
        systemd = {
          enable = true;
        };
      };
    };

    services = {
      swayosd.enable = true;
    };
    
    wayland.windowManager.sway = {
      enable = true;

      config = {
        modifier = mod;
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
          "${mod}+Shift+${ws}" = "move container to workspace ${ws}";
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
            "${mod}+Return" = "exec --no-startup-id ${term}";
            "Alt+space" = "exec --no-startup-id wofi --show drun,run";
            "Alt+Tab" = "exec ~/.cargo/bin/swayr switch-workspace";
            "${mod}+Tab" = "exec ~/.cargo/bin/swayr switch-window";


            "${mod}+a" = "focus parent";
            "${mod}+c" = "focus child";

            "${mod}+f" = "fullscreen toggle";
            "${mod}+k" = "kill";

            "${mod}+g" = "split h";
            "${mod}+v" = "split v";
            "${mod}+e" = "layout toggle split";
            "${mod}+s" = "layout stacking";
            "${mod}+w" = "layout tabbed";
            "${mod}+r" = "mode resize";

            "${mod}+space" = "exec fuzzel";

            "${mod}+n" = "scratchpad show";
            "${mod}+Shift+n" = "move scratchpad";
          
            "${mod}+l" = "focus mode_toggle";
            "${mod}+Shift+l" = "floating toggle";

            "${mod}+Shift+r" = "exec swaymsg reload";

            "${mod}+z" = "exec --no-startup-id ${pkgs.sway-contrib.grimshot}/bin/grimshot copy area";
            
            "${mod}+Ctrl+l" = "exec ${pkgs.swaylock-fancy}/bin/swaylock-fancy";
            "${mod}+Ctrl+q" = "exit";

            # Volume
            "XF86AudioRaiseVolume"= "exec 'pactl set-sink-volume @DEFAULT_SINK@ +1%'";
            "XF86AudioLowerVolume"= "exec 'pactl set-sink-volume @DEFAULT_SINK@ -1%'";
            "XF86AudioMute"= "exec 'pactl set-sink-mute @DEFAULT_SINK@ toggle'";
          }
        ];

        modes = {
          resize = {
            Escape = "mode default";
            Return = "mode default";
            Left   = "resize shrink width 100 px";
            Down   = "resize grow height 100 px";
            Up     = "resize shrink height 100 px";
            Right  = "resize grow width 100 px";
            h = "resize shrink width 25 px";
            a = "resize grow height 25 px";
            e = "resize shrink height 25 px";
            i = "resize grow width 25 px";
          };
        };

        startup = [
          { command = "waybar -c /home/david/.config/waybar/config.jsonc"; }
          { command = "swaybg -i ~/Pictures/wallpaper/dark-water.jpg -m fill"; }
          { command = "firefox"; }
        ];

        colors.focused = {
          background = "#285577";
          border = "#ff9900";
          childBorder = "#285577";
          indicator = "#2e9ef4";
          text = "#ffffff";
        };
        
        bars = [];
        floating.titlebar = true;
        window.titlebar = false;
      };
      # swaynag.enable = false;
      wrapperFeatures.gtk = true;
      extraOptions = [ "--unsupported-gpu" ];
    };
  }; # home-manager directives
}
