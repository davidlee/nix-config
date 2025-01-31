{
  pkgs,
  host,
  username,
  ...
}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    # oh-my-zsh = {
    #   enable = true;
    #   plugins = ["git" "sudo"];
    # };
    antidote = {
      enable = true; 
      # plugins = ["git" "sudo"];
    };
    history.size = 10000;
    profileExtra = ''

      bindkey -e

      setopt extended_glob
      setopt glob_dots
      setopt no_complete_aliases

      autoload zmv

      # Fix Alt-BSPC & word navigation
      # 
      WORDCHARS='*?_-.[]~=&;!#$%^(){}<>/ '$'\n'
      autoload -Uz select-word-style
      select-word-style normal
      zstyle ':zle:*' word-style unspecified
      
      autoload -U compinit
      setopt correct                                                  # Auto correct mistakes
      setopt extendedglob                                             # Extended globbing. Allows using regular expressions with *
      setopt nocaseglob                                               # Case insensitive globbing
      setopt glob_dots
      setopt rcexpandparam                                            # Array expension with parameters
      setopt nocheckjobs                                              # Don't warn about running processes when exiting
      setopt numericglobsort                                          # Sort filenames numerically when it makes sense
      setopt appendhistory                                            # Immediately append history instead of overwriting
      setopt histignorealldups                                        # If a new command is a duplicate, remove the older one
      setopt autocd                                                   # if only directory path is entered, cd there.
      setopt auto_pushd
      setopt pushd_ignore_dups
      setopt pushdminus

      setopt BANG_HIST                 # Treat the '!' character specially during expansion.
      setopt EXTENDED_HISTORY          # Write the history file in the ':start:elapsed;command' format.
      setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
      setopt SHARE_HISTORY             # Share history between all sessions.
      setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
      setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
      setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
      setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
      setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
      setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
      setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
      setopt HIST_VERIFY               # Do not execute immediately upon history expansion.
    '';
    initExtra = ''
      eval "$(zoxide init zsh)"
      eval "$(mcfly init zsh)"
      eval "$(direnv hook zsh)"
      export MANPAGER='nvim +Man!'
      export MCFLY_KEY_SCHEME=vim
      export MCFLY_FUZZY=2
      export MCFLY_RESULTS=50
      export MCFLY_RESULTS_SORT=LAST_RUN
      export MCFLY_INTERFACE_VIEW=BOTTOM
      export TERM=xterm-256color
      export EDITOR=nvim
      export VISUAL=nvim

      # manage dotfiles with bare repo
      # this way we can have autocomplete too
      # 
      gc() { git --work-tree=$HOME --git-dir=$HOME/.cfg $* }   
      cfg() { git --work-tree=$HOME --git-dir=$HOME/.cfg $* }   
    '';
    shellAliases = {
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
      l = "eza -lh --icons=auto"; # long list
      ls = "eza --icons=auto --group-directories-first --icons"; # short list
      ll = "eza -lh --icons --grid --group-directories-first --icons";
      la = "eza -lah --icons --grid --group-directories-first --icons";
      ld = "eza -lhD --icons=auto";
      lt = "eza --icons=auto --tree"; # list folder as tree
      jctl = "journalctl -p 3 -xb";
      mkdir = "mkdir -p";
      yz = "yazi";
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      keys = "ghostty +list-keybinds";

      nrs = "sudo nixos-rebuild switch";
      hs = "home-manager switch";
    };
  };
}
