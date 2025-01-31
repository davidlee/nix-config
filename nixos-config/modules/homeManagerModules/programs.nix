{
  pkgs,
  host,
  username,
  ...
}: {

  programs = {
  
    direnv = {
      enable = true;
      enableZshIntegration = true; 
      enableBashIntegration = true; 
      nix-direnv.enable = true;
    };

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


    skim = {
      enable = true;
      enableBashIntegration = true;
    };
 
    kitty = {
      enable = true;
      # font.name = "MonoLisa";
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

      # font_family      family="MonoLisa Nerd Font Mono" style=Regular features=
      bold_font        auto 
      italic_font      auto
      bold_italic_font auto

      window_margin_width 10

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
        hs = "home-manager switch";
      };
      history.size = 10000;
    
      envExtra = ''
      '';

      initExtra = ''
      bindkey -e

      setopt extended_glob
      setopt glob_dots
      setopt no_complete_aliases

      autoload zmv

      # Fix Alt-BSPC
      # overkill: https://mikebian.co/fixing-word-navigation-in-zsh/
      # 
      #autoload -U select-word-style
      #select-word-style
      
      WORDCHARS='*?_-.[]~=&;!#$%^(){}<>/ '$'\n'
      autoload -Uz select-word-style
      select-word-style normal
      zstyle ':zle:*' word-style unspecified
      

      # manage dotfiles with bare repo
      # this way we can have autocomplete too
      # 
      gc() { git --work-tree=$HOME --git-dir=$HOME/.cfg $* }   

      '';
    };

    waybar =  {
      enable = true;
    };
  };
  
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

}
