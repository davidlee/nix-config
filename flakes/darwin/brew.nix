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
    #
    # Note: currently disabled due to excessive install time
    # 
    # masApps = {
    #   Xcode = 497799835;
    # };
     brews = [
       # "jordanbaird-ice"
      "jupyterlab"
      "dnote"
      "cmdg"
      "mlx"
      "llm"
      "llvm@18"
      "python3"
      "node"
      "surreal"
      "television"
    ];
    casks = [
      "firefox"
      "anaconda"
      "zoom"
      "obs"
      "aerospace"
      "iina"
      "jordanbaird-ice"
      "google-chrome"
      "hammerspoon"
      "1password-cli"
      "beeper"
      "grain-lang/tap/grain"
      # "1password"
      # "raycast"
      # "spotify"
      # "slack"
      # "discord"
      # "visual-studio-code"
    ];
    taps = [
      "nikitabobko/aerospace"
      "homebrew/services"
      "dnote/dnote"
      "cutzenfriend/homebrew-cmdg"
      "surrealdb/surreal"
    ];

    extraConfig = ''
    '';
  };
}
