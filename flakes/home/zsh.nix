{
  lib,
  ...
}: {

  # NOTE using antidote vanilla because it's easier to reason about
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    defaultKeymap = "emacs";
    # manage w/ antidote
    enableCompletion = false;

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
    
    envExtra = ''
      source $HOME/.config/zsh/env.zsh
    '';

    profileExtra = ''
      source $HOME/.config/zsh/profile.zsh
    '';

    initContent = let
      zshConfigEarlyInit = lib.mkOrder 500 ''
        source $HOME/.config/zsh/initEarly.zsh
      '';
      zshConfigLateInit = lib.mkOrder 1000 ''
        source $HOME/.config/zsh/init.zsh
      '';
    in lib.mkMerge [ zshConfigEarlyInit zshConfigLateInit ];

    loginExtra = ''
      source $HOME/.config/zsh/login.zsh
    '';
    
  };
}
