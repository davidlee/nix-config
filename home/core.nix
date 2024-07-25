{ pkgs, ... }:

{
  home.packages = with pkgs; [

      darwin.trash
      sad
      semgrep
      antidote 
      aria2
      aspell
      autoconf
      bat
      broot
      bun
      caddy
      chez
      chicken
      clangStdenv
      corepack_latest
      coreutils
      curl
      d2
      delta
      difftastic
      direnv
      nix-direnv
      docutils
      emacs-nox
      exercism
      eza
      fd
      file
      fontconfig
      fzf
      gawk
      gh
      ghc
      git
      gitu
      glib
      glow
      gnused
      gnutar
      graphviz
      guile
      helix
      hello
      hexyl
      htop
      httpie
      jankyborders
      jq
      jq
      kakoune
      kakoune
      kitty
      lazygit
      less
      lf
      libclang
      libiconv
      lld
      lsd
      lunarvim
      markdown-oxide
      marksman
      ncdu
      nerdfonts
      nethack
      nil
      ninja
      nix-search-cli
      nmap
      nnn
      nodejs_latest
      nushell
      overmind
      p7zip
      pipx
      pixman
      pnpm
      pstree
      cmake
      # python3
      # virtualenv
      # python3.12
      python312
      python312Packages.pywatchman
      qmk
      racket
      racket
      ranger
      rbenv
      ripgrep
      ruby
      rustup
      shortcat
      skhd
      socat
      sqlite
      starship
      stdenv
      stow
      syncthing
      taskwarrior
      tldr
      tmux
      tpnote
      tree
      tree-sitter
      unar
      unzip
      vit
      watchman
      wezterm
      wget
      which
      xz
      yabai
      yazi
      yq-go
      zellij
      zig
      zip
      zk
      zoxide
      zsh
      zstd

];


  programs = {
    helix.defaultEditor = true;

    neovim = {
      enable = true;
      vimAlias = true;
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [ 
        "--cmd cd" 
        "--hook pwd" 
      ];
    };

    zk.enable = true;

    kitty = {
      enable = true;
      font.name = "Monolisa";
      settings = {
        allow_remote_control = true;
        listen_on                    = "unix:/private/tmp/kitty";
        clipboard_control            = "write-clipboard write-primary read-clipboard read-primary";
        cursor_blink_interval        = "0.25";
        dim_opacity                  = "0.75";
        visual_bell_duration         = "0.1";
        cursor_shape                 = "beam";
        font_family                  = "Monolisa";
        macos_custom_beam_cursor     = true;
        macos_option_as_alt          = true;
        macos_traditional_fullscreen = true;
        resize_in_steps              = true;
        tab_bar_style                = "powerline";
        window_border_width          = "1px";
        enabled_layouts              = "*";
      };

      extraConfig = ''
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
    

    zellij = {
      # enable = true;
      enableZshIntegration = true;
    };

    yazi = {
      enable = true;
      enableZshIntegration = true;
    };

    eza.enable = true;
    git.enable = true;

    direnv.enable = true;
    direnv.nix-direnv.enable = true;

    skim = {
      enable = true;
      enableBashIntegration = true;
    };

    #
    # ZSH
    # 

    zsh.dotDir = ".config/zsh";

    # zsh.enableFzfCompletion = true; 
    zsh.syntaxHighlighting.enable = true;
    zsh.antidote.enable = true;
    zsh.antidote.plugins = [
      "https://github.com/peterhurford/up.zsh"
      "rummik/zsh-tailf"
      "mattmc3/zman"
      "agkozak/zsh-z"
      "ohmyzsh/ohmyzsh path:lib/clipboard.zsh"
      "ohmyzsh/ohmyzsh path:plugins/copybuffer"
      "ohmyzsh/ohmyzsh path:plugins/copyfile"
      "ohmyzsh/ohmyzsh path:plugins/copypath"
      "ohmyzsh/ohmyzsh path:plugins/colorize"
      "ohmyzsh/ohmyzsh path:plugins/extract"
      "ohmyzsh/ohmyzsh path:plugins/magic-enter"
      "ohmyzsh/ohmyzsh path:plugins/wd"
      "belak/zsh-utils path:history"
      "belak/zsh-utils path:utility"
      "belak/zsh-utils path:editor"
      "zdharma-continuum/fast-syntax-highlighting kind:defer"
      "zsh-users/zsh-completions path:src kind:fpath"
      "Aloxaf/fzf-tab"
      "belak/zsh-utils path:completion"
    ];

    # .zshenv
    zsh.envExtra = ''
      export DIFFPROG='delta'
      export MANPAGER='nvim +Man!'
      
      export GITHUB_OAUTH_TOKEN=op://Private/y46igzo35i67alyfkbeu7yew6a/token

      export ZMK_CONFIG="/Users/davidlee/dev/keeb-zmk-config/config"

      # taskwarrior - set primary
      if [[ `hostname` = fusillade ]]; then 
        export TASKRC_RECURRENCE=on
      else
        export TASKRC_RECURRENCE=off
      fi
    '';
    
    # .zshrc
    zsh.initExtra = ''
    setopt extended_glob
    setopt glob_dots
    setopt no_complete_aliases

    autoload zmv

    ## yazi
    function yy() {
    	local tmp="$(mktemp -t "yazi-cwd.XXXXX")"
    	yazi "$@" --cwd-file="$tmp"
    	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    		cd -- "$cwd"
    	fi
    	rm -f -- "$tmp"
    }

    '';

  };
}
