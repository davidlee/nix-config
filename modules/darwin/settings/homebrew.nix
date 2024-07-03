{ pkgs, ... }: {
  homebrew = {
    brewPrefix = "/opt/homebrew/bin";
    enable = true;
    caskArgs.no_quarantine = true;
    global = {
      brewfile = true;
      # lockfiles = true;
    };
    casks = [ 
      # "raycast"
      # "firefox"
      # "spotify"
      # "slack"
      # "visual-studio-code"
      # "zoom"
      # "brave-browser"
      # "intellij-idea"
      # "font-sf-mono-nerd-font"
      "obs"
      # "aerospace"
      "aerospace"
      # "telegram"
      # "ncdu"
    ];
    taps = [
      "nikitabobko/aerospace"
      # "nikitabobko/tap/aerospace"
      # "homebrew/core"
      # "homebrew/cask"
      # "homebrew/cask-fonts"
      # "d12frosted/emacs-plus"
      # "xorpse/formulae"
      # "cmacrae/formulae"
    ];
    # brews = [ "trippy" ];

    extraConfig = ''
    '';
  };
}
