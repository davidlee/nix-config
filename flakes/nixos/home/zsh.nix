{
  pkgs,
  host,
  username,
  ...
}: {
  # environment.pathsToLink = [ "/share/zsh" ];

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

    # oh-my-zsh = {
    #   enable = true;
    #   plugins = ["git" "sudo"];
    # };
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

      export EDITOR=nvim
      export VISUAL=nvim
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
      eval "$(zoxide init zsh)"
      eval "$(mcfly init zsh)"
      eval "$(direnv hook zsh)"

      # manage dotfiles with bare repo
      gc() { git --work-tree=$HOME --git-dir=$HOME/.cfg $* }   
      cfg() { git --work-tree=$HOME --git-dir=$HOME/.cfg $* }   
    '';
    shellAliases = {
      # scr = "grim -g $(slurp)";
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
      # ls = "eza --icons=auto --group-directories-first --icons"; # short
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
    };
  };
}
