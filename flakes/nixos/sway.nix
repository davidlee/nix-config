{
  pkgs,
  username,
  lib,
  ...
}:
let
  mod = "Mod4";
  term = "${pkgs.ghostty}/bin/ghostty";
in {

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
    ];

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
            "Alt+Tab" = "exec swayr switch-window";
            "${mod}+Tab" = "exec swayr switch-to-urgent-or-lru-window";
            "${mod}+p" = "exec --no-startup-id ${term}";

            "--release ${mod}" = "exec swayr nop";

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
          { command = "waybar -c $HOME/.config/waybar/config.jsonc"; }
          { command = "blueman-tray"; }
          { command = "swaybg -i ~/Pictures/wallpaper/dark-water.jpg -m fill"; }
          { command = "env RUST_BACKTRACE=1 RUST_LOG=swayr=debug swayrd > /tmp/swayrd.log 2>&1"; }
          { command = "swayosd-server"; }
          { command = "floorp"; }
        ];
        
        # use Menu as Compose key
        input."*".xkb_options = "compose:menu";
        
        bars = [];
        floating.titlebar = true;
        window.titlebar = false;
      }; # /config

      # https://github.com/ErikReider/SwayOSD
      extraConfig = ''
        bindsym XF86AudioRaiseVolume exec swayosd-client --output-volume raise --max-volume 100
        bindsym XF86AudioLowerVolume exec  swayosd-client --output-volume lower 
        bindsym XF86AudioMute exec swayosd-client --output-volume mute-toggle
        bindsym XF86AudioMicMute exec swayosd-client --input-volume mute-toggle

        # Capslock (If you don't want to use the backend)
        bindsym --release Caps_Lock exec swayosd-client --caps-lock

        bindsym XF86MonBrightnessUp exec swayosd-client --brightness raise
        bindsym XF86MonBrightnessDown exec swayosd-client --brightness lower

        # bindsym XF86AudioRaiseVolume exec pactl set-sink-volume @DEFAULT_SINK@ +5%
        # bindsym XF86AudioLowerVolume exec pactl set-sink-volume @DEFAULT_SINK@ -5%
        # bindsym XF86AudioMute exec pactl set-sink-mute @DEFAULT_SINK@ toggle
        # bindsym XF86AudioMicMute exec pactl set-source-mute @DEFAULT_SOURCE@ toggle

        bindsym XF86AudioPlay exec playerctl play-pause
        bindsym XF86AudioNext exec playerctl next
        bindsym XF86AudioPrev exec playerctl previous
      '';

      wrapperFeatures.gtk = true;
      extraOptions = [ "--unsupported-gpu" ];
    };
  }; # home-manager directives
}
