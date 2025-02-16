{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;

    plugins = [
      # inputs.hy3.packages.x86_64-linux.hyprexpo
      pkgs.hyprlandPlugins.hyprexpo
      inputs.hy3.packages.x86_64-linux.hy3
      
      # inputs.hy3.packages.${pkgs.stdenv.hostPlatform.system}.hy3
      # pkgs.hyprlandPlugins.hyprscroller
      # inputs.hy3.packages.x86_64-linux.hy3
    ];

    settings = {
      debug.disable_logs = false; 

      "$mod" = "SUPER";
      "$terminal" = "kitty";
      "$menu" = "walker";
      "$browser" = "firefox";
      "$fileManager" = "nemo";
      
      bind = [
        "$mod,tab, workspace, previous"
        "$mod SHIFT, Q, exit"

        "$mod, space, exec, $menu"
        "$mod, D, exec, fuzzel"
        "$mod, X, exec, copyq show" # TODO make floating
        "$mod, grave, hyprexpo:expo, toggle"

        "$mod, G, exec, $terminal"
        "$mod, B, exec, $browser"
        "$mod, J, exec, $fileManager"

        "$mod, K, killactive"
        "$mod, P, fullscreen"
        "$mod, F, togglefloating"

        "$mod, V, hy3:makegroup, v, ephemeral"
        "$mod, H, hy3:makegroup, h, ephemeral"
        "$mod, T, hy3:makegroup, tab, ephemeral"
        
        "$mod SHIFT, V, hy3:changegroup, v"
        "$mod SHIFT, H, hy3:changegroup, h"
        "$mod SHIFT, T, hy3:changegroup, toggletab"
        "$mod, O, hy3:changegroup, opposite"
        
        "$mod, left,  hy3:movefocus, l" 
        "$mod, right, hy3:movefocus, r" 
        "$mod, up,    hy3:movefocus, u" 
        "$mod, down,  hy3:movefocus, d" 

        "$mod SHIFT, left,  hy3:movewindow, l" 
        "$mod SHIFT, right, hy3:movewindow, r" 
        "$mod SHIFT, up,    hy3:movewindow, u" 
        "$mod SHIFT, down,  hy3:movewindow, d" 

        # "$mod CTRL, left,  hy3:movewindow, l" 
        # "$mod CTRL, right, hy3:movewindow, r" 
        # "$mod CTRL, up,    hy3:movewindow, u" 
        # "$mod CTRL, down,  hy3:movewindow ,d" 

        "ALT, tab, hy3:focustab, r, wrap"
        "ALT SHIFT, tab, hy3:focustab, l, wrap"

        "$mod, home,      hy3:changefocus, top" 
        "$mod, pagedown,  hy3:changefocus, lower" 
        "$mod, pageup,    hy3:changefocus, raise" 
        "$mod, end,       hy3:changefocus, bottom" 
        "$mod, end,       hy3:changefocus, bottom" 
        "$mod, backslash, hy3:changefocus, tab" 

        "$mod, question, hy3:debugnodes"
        
        # "$mod ALT, left,  hy3:focustab, l" 
        # "$mod ALT, right, hy3:focustab, r" 
        # "$mod ALT, up,    hy3:focustab, u" 
        # "$mod ALT, down,  hy3:focustab ,d" 
        
        "$mod, tab, hy3:togglefocuslayer"

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
          force_default_wallpaper = 0 # Set to 0 or 1 to disable the anime mascot wallpapers
          disable_hyprland_logo = true 
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

          layout = hy3
          # layout = master
          # layout = dwindle
          # layout = scroller
      }

      plugin {
        hy3 {
          
        }
      }

      animations {
        enabled = 0
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


      # clipboard: copyq is started as a service
      # 
      # 
      # exec-once = wl-paste --type text --watch cliphist store 
      # exec-once = wl-paste --type image --watch cliphist store
      #
      # exec-once = clipse -listen # run listener on startup
      # 
      # exec-once = copyq --start-server
      # 
      # exec-once = waybar
      
      exec-once = swaybg -i ~/Pictures/wallpapers/desktop.jpg
      exec-once = walker --gapplication-service

      windowrulev2 = noanim,class:() # ensure you have a floating window class set if you want this behavior

      windowrulev2 = float,class:(clipse) # ensure you have a floating window class set if you want this behavior
      windowrulev2 = size 622 652,class:(clipse) # set the size of the window as necessary
    '';
  };
}
