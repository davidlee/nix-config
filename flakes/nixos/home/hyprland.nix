{
  config,
  pkgs,
  hy3,
  inputs,
  ...
}: {

  # TODO mave this somewhere
  home.pointerCursor = {
    name = "phinger-cursors-light";
    package = pkgs.phinger-cursors;
    size = 32;
    gtk.enable = true;
    x11 = {
      enable = true;
      defaultCursor = "phinger-cursors-light";
    };
  };

  wayland.windowManager.sway = {
    enable = true;
    config = {
      modifier = "Mod4";
      terminal = "ghostty";
      gaps = {
        smartGaps = true;
        smartBorders = "on";
        outer = 5;
      };
    };
    # swaynag.enable = false;
    extraOptions = [ "--unsupported-gpu" ];
  };

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;

    ## ERRORS
    # plugins = [ pkgs.hyprlandPlugins.hyprscroller ];
    plugins = [
      # hy3.packages.${pkgs.stdenv.hostPlatform.system}.hy3
      # pkgs.hyprlandPlugins.hyprscroller
      # inputs.hy3.packages.x86_64-linux.hy3
    ];

    settings = {
      "$mod" = "SUPER";
      "$terminal" = "kitty";
      #"$menu" = "wofi --show drun";
      "$menu" = "walker";
      "$fileManager" = "nemo";
      
      # is it really worth keeping these in nix format?
      bind = [
        "$mod, Q, exec, $terminal"
        "$mod, M, exit"
        "$mod, N, fullscreen"
        "$mod, R, exec, $menu"
        "$mod, space, exec, $menu"
        "$mod, K, killactive"
        "$mod, E, exec, $fileManager"
        "$mod, V, togglefloating"
        "$mod, G, exec, ghostty"

        # "$mod, D, scroller:toggleoverview"
        # "$mod, J, scroller:jump"
        
        "$mod, left, movefocus, l" 
        "$mod, right, movefocus, r" 
        "$mod, up, movefocus, u" 
        "$mod, down, movefocus, d" 

        "$mod CTRL, left, movewindow, l" 
        "$mod CTRL, right, movewindow, r" 
        "$mod CTRL, up, movewindow, u" 
        "$mod CTRL, down, movewindow , d" 
        #"$mod CTRL, home, scroller:movewindow, begin" 
        #"$mod CTRL, end, scroller:movewindow , end" 

        #"$mod, bracketleft, scroller:setmode, row" 
        #"$mod, bracketright, scroller:setmode, col" 

        "$mod, S, togglespecialworkspace, magic" 
        "$mod SHIFT, S, movetoworkspace, special:magic" 
        
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"
      ];
      
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

    };

    extraConfig = ''
      env = XCURSOR_SIZE,24
      env = HYPRCURSOR_SIZE,24
      
      # Switch workspaces with mainMod + [0-9]
      bind = $mod, 1, workspace, 1
      bind = $mod, 2, workspace, 2
      bind = $mod, 3, workspace, 3
      bind = $mod, 4, workspace, 4
      bind = $mod, 5, workspace, 5
      bind = $mod, 6, workspace, 6
      bind = $mod, 7, workspace, 7
      bind = $mod, 8, workspace, 8
      bind = $mod, 9, workspace, 9
      bind = $mod, 0, workspace, 10

      # Move active window to a workspace with mod + SHIFT + [0-9]
      bind = $mod SHIFT, 1, movetoworkspace, 1
      bind = $mod SHIFT, 2, movetoworkspace, 2
      bind = $mod SHIFT, 3, movetoworkspace, 3
      bind = $mod SHIFT, 4, movetoworkspace, 4
      bind = $mod SHIFT, 5, movetoworkspace, 5
      bind = $mod SHIFT, 6, movetoworkspace, 6
      bind = $mod SHIFT, 7, movetoworkspace, 7
      bind = $mod SHIFT, 8, movetoworkspace, 8
      bind = $mod SHIFT, 9, movetoworkspace, 9
      bind = $mod SHIFT, 0, movetoworkspace, 10

      # Ignore maximize requests from apps. You'll probably like this.
      windowrulev2 = suppressevent maximize, class:.*

      # Fix some dragging issues with XWayland
      windowrulev2 = nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0

      # no anim for fullscreen
      windowrulev2 = noanim, class:.*,fullscreen:1

      
      # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
      dwindle {
          pseudotile = true # Master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
          preserve_split = true # You probably want this
      }

      # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
      master {
          new_status = master
      }

      # https://wiki.hyprland.org/Configuring/Variables/#misc
      misc {
          force_default_wallpaper = -1 # Set to 0 or 1 to disable the anime mascot wallpapers
          disable_hyprland_logo = false # If true disables the random hyprland logo / anime girl background. :(
      }

      # https://wiki.hyprland.org/Configuring/Variables/#general
      general {
          gaps_in = 5
          gaps_out = 20

          border_size = 2

          # https://wiki.hyprland.org/Configuring/Variables/#variable-types for info about colors
          col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
          col.inactive_border = rgba(595959aa)

          # Set to true enable resizing windows by clicking and dragging on borders and gaps
          resize_on_border = false

          # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
          allow_tearing = true

          layout = dwindle
          # layout = scroller
      }
      decoration {
          rounding = 10

          # Change transparency of focused and unfocused windows
          active_opacity = 1.0
          inactive_opacity = 0.9

          shadow {
              enabled = true
              range = 4
              render_power = 3
              color = rgba(1a1a1aee)
          }

          # https://wiki.hyprland.org/Configuring/Variables/#blur
          blur {
              enabled = true
              size = 3
              passes = 1

              vibrancy = 0.1696
          }
      }

      exec-once = clipse -listen # run listener on startup
      exec-once = swaybg -i ~/Downloads/dock.png
      exec-once = copyq --start-server
      exec-once = walker --gapplication-service


      windowrulev2 = float,class:(clipse) # ensure you have a floating window class set if you want this behavior
      windowrulev2 = size 622 652,class:(clipse) # set the size of the window as necessary

      bind = SUPER, V, exec,  <terminal name> --class clipse -e 'clipse' 

      # Example: bind = SUPER, V, exec, alacritty --class clipse -e 'clipse'
    '';
  };
}
