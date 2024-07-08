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
       # "jordanbaird-ice"
    ];
    casks = [
      "firefox"
      "zoom"
      "obs"
      "aerospace"
      "iina"
      "jordanbaird-ice"
      "intellij-idea"
      "google-chrome"
      "hammerspoon"
      # "raycast"
      # "spotify"
      # "slack"
      # "discord"
      # "visual-studio-code"
    ];
    taps = [
      "nikitabobko/aerospace"
      "homebrew/services"
    ];

    extraConfig = ''
    '';
  };
}
