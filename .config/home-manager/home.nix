{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "david";
  home.homeDirectory = "/home/david";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # hello
    # zellij
    # ncdu
    hyprland
    hyprlandPlugins.hyprscroller

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/david/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "hx";
    DIFFPROG = "delta";
    MANPAGER = "nvim +Man!";
    ZMK_CONFIG = "";
    GITHUB_OAUTH_TOKEN = "";

    XCURSOR_SIZE = 24;
    NIXOS_OZONE_WL = 1;
  };

  home.pointerCursor = {
    name = "phinger-cursors-light";
    package = pkgs.phinger-cursors;
    size = 32;
    gtk.enable = true;
  };

  programs = {
    helix.defaultEditor = true;

    neovim = {
      enable = true;
      vimAlias = true;
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
      options = [ 
        "--cmd cd" 
        "--hook pwd" 
      ];
    };

    nushell.enable = true;
    starship = {
      enable = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
    };
    carapace = {
      enable = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
    };

    zk.enable = true;

    zellij = {
      # enable = true;
      enableZshIntegration = true;
    };

    yazi = {
      enable = true;
      enableZshIntegration = true;
    };

    eza.enable = true;
    # git.enable = true;

    direnv.enable = true;
    direnv.nix-direnv.enable = true;

    skim = {
      enable = true;
      enableBashIntegration = true;
    };
 
    kitty = {
      enable = true;
      font.name = "MonoLisa";
      settings = {
        allow_remote_control         = true;
        listen_on                    = "tcp:localhost:0";
        clipboard_control            = "write-clipboard write-primary read-clipboard read-primary";
        cursor_blink_interval        = "0.25";
        dim_opacity                  = "0.75";
        visual_bell_duration         = "0.1";
        cursor_shape                 = "beam";
        # font_family                  = "Monolisa";
        macos_custom_beam_cursor     = true;
        macos_option_as_alt          = true;
        macos_traditional_fullscreen = true;
        resize_in_steps              = true;
        tab_bar_style                = "powerline";
        window_border_width          = "1px";
        enabled_layouts              = "*";
      };

      extraConfig = ''

      font_family      family="MonoLisa Nerd Font Mono" style=Regular features='+dlig +liga +subs +sups' 
      bold_font        auto 
      italic_font      auto
      bold_italic_font auto

      action_alias new_tab launch --type=tab --cwd=current

      map kitty_mod+space new_tab_with_cwd
      map kitty_mod+e     new_tab_with_cwd hx

      map kitty_mod+.     move_tab_forward
      map kitty_mod+,     move_tab_backward

      map kitty_mod+]     next_window
      map kitty_mod+[     previous_window

      map kitty_mod+escape kitty_shell window

      map kitty_mod+t goto_layout tall
      map kitty_mod+s goto_layout stack

      map kitty_mod+w swap_with_window
      map kitty_mod+z focus_visible_window
      
      '';
    };
    
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      antidote = {
        enable = true; 
        plugins = [];
      };

      shellAliases = {
        ll = "ls -l";
        nrs = "sudo nixos-rebuild switch";
        hms = "home-manager switch";
      };
      history.size = 10000;
    
      envExtra = ''
      '';

      initExtra = ''
      setopt extended_glob
      setopt glob_dots
      setopt no_complete_aliases

      autoload zmv

      # manage dotfiles with bare repo
      # this way we can have autocomplete too
      gc() { git --work-tree=$HOME --git-dir=$HOME/.cfg $* }
      
      '';
    };

    waybar =  {
      enable = true;
    };
  };
  
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;
    # withUWSM = true;

    ## ERRORS
    # plugins = [ pkgs.hyprlandPlugins.hyprscroller ];

    settings = {
      "$mod" = "SUPER";
      "$terminal" = "kitty";
      "$menu" = "wofi --show drun";
      "$fileManager" = "dolphin";
      
      # is it really worth keeping these in nix format?
      bind = [
        "$mod, Q, exec, $terminal"
        "$mod, M, exit"
        "$mod, N, fullscreen"
        "$mod, R, exec, $menu"
        "$mod, C, killactive"
        "$mod, E, exec, $fileManager"
        "$mod, V, togglefloating"
        "$mod, D, scroller:toggleoverview"
        "$mod, J, scroller:jump"
        
        "$mod, left, movefocus, l" 
        "$mod, right, movefocus, r" 
        "$mod, up, movefocus, u" 
        "$mod, down, movefocus, d" 

        "$mod CTRL, left, movewindow, l" 
        "$mod CTRL, right, movewindow, r" 
        "$mod CTRL, up, movewindow, u" 
        "$mod CTRL, down, movewindow , d" 
        "$mod CTRL, home, scroller:movewindow, begin" 
        "$mod CTRL, end, scroller:movewindow , end" 

        "$mod, bracketleft, scroller:setmode, row" 
        "$mod, bracketright, scroller:setmode, col" 

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
          layout = scroller
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

      windowrulev2 = float,class:(clipse) # ensure you have a floating window class set if you want this behavior
      windowrulev2 = size 622 652,class:(clipse) # set the size of the window as necessary

      bind = SUPER, V, exec,  <terminal name> --class clipse -e 'clipse' 

      # Example: bind = SUPER, V, exec, alacritty --class clipse -e 'clipse'
    '';
  };
}
