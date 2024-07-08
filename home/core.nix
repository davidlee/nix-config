{ pkgs, ... }:

{
  home.packages = with pkgs; [

      antidote # this shit even connected?
      aria2
      aspell
      autoconf
      bat
      broot
      bun
      caddy
      clangStdenv
      corepack_latest
      coreutils
      curl
      d2
      delta
      difftastic
      direnv
      docutils
      emacs
      exercism
      eza
      fd
      file
      fontconfig
      fzf
      gawk
      gh
      git
      gitu
      glib
      glow
      gnused
      gnutar
      graphviz
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
      less
      lf
      libclang
      libiconv
      lld
      lsd
      markdown-oxide
      marksman
      ncdu
      nerdfonts
      nethack
      nil
      ninja
      nix-direnv
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
      python3
      python3
      qmk
      racket
      ranger
      rbenv
      ripgrep
      ruby
      rustup
      shortcat
      sketchybar
      socat
      sqlite
      starship
      stdenv
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
      wget
      which
      xz
      yazi
      yq-go
      zellij
      zip
      zk
      zoxide
      zsh
      zstd
      stow

      python312Packages.pywatchman
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

    eza.enable = true;
    git.enable = true;

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

    # skim provides a single executable: sk.
    # Basically anywhere you would want to use grep, try sk instead.
    skim = {
      enable = true;
      enableBashIntegration = true;
    };
  };
}
