{
  pkgs,
  hostname,
  username,
  ...
}: {

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    autocd = true;

    defaultKeymap = "emacs";
    dotDir = ".config/zsh";

    history.size = 10000;
    
    history = {
      ignoreDups = true;
      ignoreAllDups = true;
      extended = true;
      findNoDups = true;
    };

    envExtra = ''
      export MANPAGER='nvim +Man!'
      export MCFLY_KEY_SCHEME=vim
      export MCFLY_FUZZY=2
      export MCFLY_RESULTS=50
      export MCFLY_RESULTS_SORT=LAST_RUN
      export MCFLY_INTERFACE_VIEW=BOTTOM
      export TERM=xterm-256color

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
      autoload zmv

      path+=~/.local/bin
      path+=~/.cargo/bin
      path+=$PWD/bin

      typeset -U path

      # Fix Alt-BSPC & word navigation
      # 
      WORDCHARS='*?_-.[]~=&;!#$%^(){}<>/ '$'\n'
      autoload -Uz select-word-style
      select-word-style normal
      zstyle ':zle:*' word-style unspecified
    '';
    # initExtraBeforeCompInit = "";
    initExtra = ''
      # TODO manage this stuff where it doesn't need a `nixos-rebuild switch` to take effect
      # manage dotfiles with bare repo
      gc() { git --work-tree=$HOME --git-dir=$HOME/.cfg $* }   
      prv() { git --work-tree=$HOME --git-dir=$HOME/.private $* }   

      om() { $* --log-format internal-json -v |& nom --json }

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
      # util / override
      scr = "grimshot save area";
      cat = "bat --style snip --style changes --style header";
      mkdir = "mkdir -p";
     
      # cd
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      # list files
      vdir = "vdir --color=auto";
      dir = "dir --color=auto";
      l = "eza -lh"; 
      ll = "eza -lh --grid --group-directories-first";
      la = "eza -lah --grid --group-directories-first";
      ld = "eza -lhD";
      lt = "eza --tree"; 

      # grep
      egrep = "grep -E --color=auto";
      fgrep = "grep -F --color=auto";
      grep = "grep --color=auto";
      
      # editors
      v = "nvim";
      zed = "zeditor";

      # TUI shortcuts
      yz = "yazi";
      lg = "lazygit";
      ip = "ip -color";

      # nix
      ngc = "nix-collect-garbage --delete-old && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";
      opts = "man home-configuration.nix";
      nrs = "sudo nixos-rebuild switch";
      
      # taskwarrior
      t = "task";
      ta = "task add";
      tc = "task context";
      tl = "task list";

  
      h = "harsh";
      hc ="$VISUAL ~/.config/harsh/habits";
      hl = "$VISUAL ~/.config/harsh/log";

      # miscellany
      cl = "clock-rs -Bbt --fmt '%Y-%m-%d'";
    };
  };
}
