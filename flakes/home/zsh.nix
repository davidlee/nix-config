{
  pkgs,
  hostname,
  username,
  ...
}: {

  # evironment.pathsToLink = [ "/share/zsh" ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    autocd = true;
    history = {
      ignoreDups = true;
      ignoreAllDups = true;
      extended = true;
      findNoDups = true;
    };
    dotDir = ".config/zsh";

    antidote = {
      enable = true; 
      # plugins = ["git" "sudo"];
    };
    history.size = 10000;

    envExtra = ''
      export MANPAGER='nvim +Man!'
      export MCFLY_KEY_SCHEME=vim
      export MCFLY_FUZZY=2
      export MCFLY_RESULTS=50
      export MCFLY_RESULTS_SORT=LAST_RUN
      export MCFLY_INTERFACE_VIEW=BOTTOM
      export TERM=xterm-256color

      # export ELECTRON_OZONE_PLATFORM_HINT=wayland

      # dumb flickering because nvidia drivers
      export ELECTRON_OZONE_PLATFORM_HINT=x11 

      export EDITOR=nvim
      export VISUAL=hx
    '';

    profileExtra = ''
      setopt extended_glob
      setopt glob_dots
      setopt no_complete_aliases
     
      setopt extendedglob
      setopt glob_dots
      setopt auto_pushd
      setopt pushd_ignore_dups
      setopt pushdminus
      setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
      setopt HIST_VERIFY               # Do not execute immediately upon history expansion.
    '';
    initExtraFirst = '';
      bindkey -e
      autoload zmv

      path+=~/.local/bin
      path+=$PWD/bin

      typeset -U path

      # Fix Alt-BSPC & word navigation
      # 
      WORDCHARS='*?_-.[]~=&;!#$%^(){}<>/ '$'\n'
      autoload -Uz select-word-style
      select-word-style normal
      zstyle ':zle:*' word-style unspecified
    '';
    initExtraBeforeCompInit = ''
    '';
    initExtra = ''
      # TODO manage this stuff where it doesn't need a `nixos-rebuild switch` to take effect
      # manage dotfiles with bare repo
      gc() { git --work-tree=$HOME --git-dir=$HOME/.cfg $* }   
      cfg() { git --work-tree=$HOME --git-dir=$HOME/.cfg $* }   


      # manage text files
      export ORG_DIR=~/org
      
      wk() {
        date +"$ORG_DIR/%Y/wk/%Ywk%U.md"
      }

      day() {
        date +"$ORG_DIR/%Y/dd/%F.md"
      }

      mo() {
        date +"$ORG_DIR/%Y/mo/%m.md"
      }
      
      ewk() {
        $VISUAL $(wk) -w $ORG_DIR
      }

      eday() {
        $VISUAL $(day) -w $ORG_DIR
      }

      emo() {
        $VISUAL $(mo) -w $ORG_DIR

      }
      

    '';
    shellAliases = {
      t = "task";
      ta = "task add";
      tl = "task list";
      
      scr = "grimshot save area";
      v = "nvim";
      ngc = "nix-collect-garbage --delete-old && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";
      opts = "man home-configuration.nix";
      zed = "zeditor";
      lg = "lazygit";
      ip = "ip -color";
      untar = "tar -zxvf ";
      egrep = "grep -E --color=auto";
      fgrep = "grep -F --color=auto";
      grep = "grep --color=auto";
      vdir = "vdir --color=auto";
      dir = "dir --color=auto";
      cat = "bat --style snip --style changes --style header";
      l = "eza -lh"; # long
      ll = "eza -lh --grid --group-directories-first";
      la = "eza -lah --grid --group-directories-first";
      ld = "eza -lhD";
      lt = "eza --tree"; # list folder as tree
      jctl = "journalctl -p 3 -xb";
      mkdir = "mkdir -p";
      yz = "yazi";
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      keys = "ghostty +list-keybinds";

      nrs = "sudo nixos-rebuild switch";
      hms = "home-manager build --flake ~/flakes/.#david";
    };
  };
}
