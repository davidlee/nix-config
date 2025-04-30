{ pkgs, username, ...} : {

  programs.hyprland.enable = true; 
  programs.hyprland.withUWSM = true;

  environment.systemPackages = [
  ];

  # environment.sessionVariables.NIXOS_OZONE_WL = "1";

  home-manager.users.${username} = {

    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;

      plugins = [
        pkgs.hyprlandPlugins.hy3
        # pkgs.hyprlandPlugins.hyprscroller
        pkgs.hyprlandPlugins.hyprexpo
        # pkgs.hyprlandPlugins.hyprfocus
        # pkgs.hyprlandPlugins.hyprspace
        # pkgs.hyprlandPlugins.hyprsplit
      ];

      settings = {
        "$mod" = "SUPER";
        "$terminal" = "kitty";
        "$menu" = "wofi --show drun";
        "$fileManager" = "nemo";
      
        bind = [
          "$mod, P, exec, $terminal"
          "$mod, F, fullscreen"
          "$mod, space, exec, $menu"
          "$mod, K, killactive"
          "$mod SHIFT, K, hy3:killactive"

          "$mod,     C,   hy3:makegroup, h"
          "$mod,     V,   hy3:makegroup, v"
          "$mod,     S,   hy3:makegroup, tab"
          "$mod,     G,   hy3:makegroup, opposite"
          
          "$mod ALT, C,   hy3:changegroup, h"
          "$mod ALT, V,   hy3:changegroup, v"
          "$mod ALT, S,   hy3:changegroup, toggletab"
          "$mod ALT, G,   hy3:changegroup, opposite"

          "$mod, E,       hy3:setephemeral, true"
          "$mod SHIFT, E, hy3:setephemeral, false"
          
          "$mod, U,       hy3:changefocus, raise"
          "$mod SHIFT, U, hy3:changefocus, lower"
          
          "$mod, O,       hy3:changefocus, tab"
          "$mod SHIFT, O, hy3:changefocus, tabnode"
          
          "$mod, Y,       hy3:changefocus, top"
          "$mod SHIFT, Y, hy3:changefocus, bottom"
          
          "$mod, L,       hy3:togglefocuslayer"
          "$mod SHIFT, L, togglefloating"
          
          "$mod CTRL, Q, exit"
          "$mod SHIFT, D, hy3:debugnodes"

          "$mod, E, exec, $fileManager"
        
          "$mod, left,  hy3:movefocus, l" 
          "$mod, right, hy3:movefocus, r" 
          "$mod, up,    hy3:movefocus, u" 
          "$mod, down,  hy3:movefocus, d" 

          "$mod ALT, left,  hy3:movefocus, l, visible" 
          "$mod ALT, right, hy3:movefocus, r, visible" 
          "$mod ALT, up,    hy3:movefocus, u, visible" 
          "$mod ALT, down,  hy3:movefocus, d, visible" 

          "$mod SHIFT, left,  hy3:movewindow, l" 
          "$mod SHIFT, right, hy3:movewindow, r" 
          "$mod SHIFT, up,    hy3:movewindow, u" 
          "$mod SHIFT, down,  hy3:movewindow , d" 

          "$mod, page_down, hy3:focustab, l"
          "$mod, page_up,   hy3:focustab, r"

          "$mod, N, togglespecialworkspace, magic" 
          "$mod SHIFT, N, movetoworkspace, special:magic" 
        
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
        bind = $mod SHIFT, 1, hy3:movetoworkspace, 1
        bind = $mod SHIFT, 2, hy3:movetoworkspace, 2
        bind = $mod SHIFT, 3, hy3:movetoworkspace, 3
        bind = $mod SHIFT, 4, hy3:movetoworkspace, 4
        bind = $mod SHIFT, 5, hy3:movetoworkspace, 5
        bind = $mod SHIFT, 6, hy3:movetoworkspace, 6
        bind = $mod SHIFT, 7, hy3:movetoworkspace, 7
        bind = $mod SHIFT, 8, hy3:movetoworkspace, 8
        bind = $mod SHIFT, 9, hy3:movetoworkspace, 9
        bind = $mod SHIFT, 0, hy3:movetoworkspace, 10

        bindl = , XF86AudioRaiseVolume, exec, swayosd-client --output-volume raise --max-volume 100
        bindl = , XF86AudioLowerVolume, exec,  swayosd-client --output-volume lower 
        bindl = , XF86AudioMute, exec, swayosd-client --output-volume mute-toggle
        bindl = , XF86AudioMicMute, exec, swayosd-client --input-volume mute-toggle
        bindl = , XF86AudioPlay, exec, playerctl play-pause
        bindl = , XF86AudioNext, exec, playerctl next
        bindl = , XF86AudioPrev, exec, playerctl previous

        # Ignore maximize requests from apps. You'll probably like this.
        windowrulev2 = suppressevent maximize, class:.*

        # Fix some dragging issues with XWayland
        windowrulev2 = nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0

        # no anim for fullscreen
        windowrulev2 = noanim, class:.*,fullscreen:1

        general {
            gaps_in = 5
            gaps_out = 20

            border_size = 1

            col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
            col.inactive_border = rgba(595959aa)

            resize_on_border = true
            allow_tearing = true

            # layout = dwindle | master | scroller | hy3
            layout = hy3
        }
        
        dwindle {
            pseudotile = true # Master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
            preserve_split = true # You probably want this
        }

        master {
            new_status = master
        }

        misc {
            force_default_wallpaper = -1 # Set to 0 or 1 to disable the anime mascot wallpapers
            disable_hyprland_logo = 1
        }

        decoration {
            rounding = 10

            active_opacity = 1.0
            inactive_opacity = 0.9

            shadow {
                enabled = true
                range = 4
                render_power = 3
                color = rgba(1a1a1aee)
            }

            blur {
                enabled = true
                size = 3
                passes = 1

                vibrancy = 0.1696
            }
        }

        plugin {
          hy3 {
            tabs {
            }
            autotile {
              enable = 1
            }
          }
        }

        input {
          kb_layout = us
          kb_variant =
          kb_model =
          kb_options = compose:menu
        }

        xwayland {
          force_zero_scaling = true
        }

        # toolkit-specific scale
        env = GDK_SCALE,2
        env = XCURSOR_SIZE,32

        exec-once = waybar -c ~/.config/waybar/config.jsonc
        exec-once = swaybg -i ~/Pictures/wallpaper/dark-water.jpg
        exec-once = gnome-keyring-daemon --start --daemonize --components=ssh,secrets && export SSH_AUTH_SOCK
        exec-once = swayosd-server
        exec-once = blueman-tray
        exec-once = 1password --silent
        exec-once = copyq --start-server

        animation = windows, 1, 1, default
      '';
    };
  };
}
