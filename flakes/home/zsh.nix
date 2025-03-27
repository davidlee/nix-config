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
        ohmyzsh/ohmyzsh path:plugins/copybuffer
        ohmyzsh/ohmyzsh path:plugins/copyfile
        ohmyzsh/ohmyzsh path:plugins/copypath
        ohmyzsh/ohmyzsh path:plugins/extract
        ohmyzsh/ohmyzsh path:plugins/globalias
        ohmyzsh/ohmyzsh path:plugins/magic-enter
        ohmyzsh/ohmyzsh path:plugins/fancy-ctrl-z
        ohmyzsh/ohmyzsh path:plugins/otp
        ohmyzsh/ohmyzsh path:plugins/zoxide

        belak/zsh-utils path:editor
        belak/zsh-utils path:history
        belak/zsh-utils path:utility
        belak/zsh-utils path:completion/functions kind:autoload post:compstyle_zshzoo_setup
        
        # aloxaf/fzf-tab  

        zsh-users/zsh-completions kind:fpath path:src
        zsh-users/zsh-autosuggestions
        zsh-users/zsh-history-substring-search  
        # zsh-users/zsh-syntax-highlighting
        zdharma-continuum/fast-syntax-highlighting  
         
        marlonrichert/zsh-autocomplete
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
