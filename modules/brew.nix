{ pkgs, ... }: {

  homebrew = {
    enable = true;
    caskArgs.no_quarantine = true;
    global = {
      brewfile = true;
      # lockfiles = true;
    };

    # Applications to install from Mac App Store using mas.
    # You need to install all these Apps manually first so that your apple account have records for them.
    # otherwise Apple Store will refuse to install them.
    # For details, see https://github.com/mas-cli/mas 
    masApps = {
      Xcode = 497799835;
    };
     brews = [
      
    ];
    casks = [
      "raycast"
      "firefox"
      "spotify"
      "slack"
      "discord"
      "visual-studio-code"
      "zoom"
      # "brave-browser"
      "intellij-idea"
      "google-chrome"
      "obs"
      "aerospace"
      "iina"
    ];
    taps = [
      "nikitabobko/aerospace"
      "homebrew/cask-fonts"
      "homebrew/services"
      "homebrew/cask-versions"
    ];
    # brews = [ ];

    extraConfig = ''
    '';
  };
}
