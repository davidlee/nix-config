{
  # pkgs,
  # hostname,
  # username,
  ...
}: {


  programs.zsh = {
    enable = true;
    # autocd = true;

    dotDir = ".config/zsh";
    defaultKeymap = "emacs";
    
    # manage these w/ antidote
    enableCompletion = false;
    syntaxHighlighting.enable = false;
    autosuggestion.enable = false;

    history = {
      ignoreAllDups = true;
      size = 10000;
      extended = true;
      ignorePatterns = [
        "rm *"
        "pkill *"
        "cp *"
        "rmdir *"
      ];
    };

    antidote = {
      enable = true;
      plugins = [''
        getantidote/use-omz

        ohmyzsh/ohmyzsh path:plugins/colored-man-pages
        ohmyzsh/ohmyzsh path:plugins/extract
        ohmyzsh/ohmyzsh path:plugins/fancy-ctrl-z
        ohmyzsh/ohmyzsh path:plugins/taskwarrior
        ohmyzsh/ohmyzsh path:plugins/1password
        ohmyzsh/ohmyzsh path:plugins/copypath
        ohmyzsh/ohmyzsh path:plugins/copybuffer
        ohmyzsh/ohmyzsh path:plugins/copyfile
        ohmyzsh/ohmyzsh path:plugins/colorize
        ohmyzsh/ohmyzsh path:plugins/fzf
        ohmyzsh/ohmyzsh path:plugins/foot
        ohmyzsh/ohmyzsh path:plugins/gh
        ohmyzsh/ohmyzsh path:plugins/github
        ohmyzsh/ohmyzsh path:plugins/eza
        ohmyzsh/ohmyzsh path:plugins/rust
        ohmyzsh/ohmyzsh path:plugins/tailscale
        ohmyzsh/ohmyzsh path:plugins/systemd
        ohmyzsh/ohmyzsh path:plugins/globalias
        
        # ohmyzsh/ohmyzsh path:plugins/command-not-found
        # ohmyzsh/ohmyzsh path:plugins/httpie
        # ohmyzsh/ohmyzsh path:plugins/kitty
        # ohmyzsh/ohmyzsh path:plugins/ngrok
        # ohmyzsh/ohmyzsh path:plugins/nmap
        # ohmyzsh/ohmyzsh path:plugins/podman
        # ohmyzsh/ohmyzsh path:plugins/magic-enter
        # ohmyzsh/ohmyzsh path:plugins/otp

        # marlonrichert/zsh-autocomplete
        aloxaf/fzf-tab  

        belak/zsh-utils path:editor
        belak/zsh-utils path:history
        belak/zsh-utils path:utility
        belak/zsh-utils path:completion/functions kind:autoload post:compstyle_zshzoo_setup

        zsh-users/zsh-completions kind:fpath path:src
        zsh-users/zsh-autosuggestions
        zsh-users/zsh-history-substring-search  
        zdharma-continuum/fast-syntax-highlighting
      ''];
    };
    
    envExtra = ''
      source $HOME/.config/zsh/env.zsh
    '';

    profileExtra = ''
      source $HOME/.config/zsh/profile.zsh
    '';

    initExtra = ''
      source $HOME/.config/zsh/init.zsh
    '';

    loginExtra = ''
      source $HOME/.config/zsh/login.zsh
    '';
    
  };
}
