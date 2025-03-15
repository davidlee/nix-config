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
  services = {
    blueman.enable = true;
  };

  security = {
    polkit.enable = true;
    pam.services.swaylock = {};
  };

  programs = {
    sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };
    
    uwsm = {
      enable = true;
      waylandCompositors = {
        sway = {
          prettyName = "Sway";
          comment = "Sway compositor managed by UWSM";
          binPath = "/run/current-system/sw/bin/sway";
        };
      };
    };
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
        settings = {
          
          mainBar = {
            layer = "top";
            position = "top";
            height = 30;
            modules-left = [ "sway/workspaces" "sway/mode" "wlr/taskbar" "tray" "gamemode" ];
            modules-center = [ "sway/window" ];
            modules-right = [ "clock" ];

            "sway/workspaces" = {
            };

            "wlr/taskbar" = {
              on-click = "activate";
              on-click-right = "maximise";
              on-click-middle = "close";
              tooltip-format = "{title}";
            };

            tray = {
              spacing = 10;
              icon-size = 16; 
              show-passive-items = true;
            };

            clock = {
              format = "Wk{:%V | %a %d %B | %I:%M:%S}";
            };
          };
        };
      };
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
            "${mod}+Return" = "exec --no-startup-id ${pkgs.foot}/bin/foot";
            "Alt+space" = "exec --no-startup-id wofi --show drun,run";
            "Alt+Tab" = "exec swayr switch-workspace";
            "${mod}+Tab" = "exec swayr switch-window";


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
  }; # home-manager directives
}
