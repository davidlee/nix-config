_: {
  homebrew = {
    enable = true;
    caskArgs.no_quarantine = true;
    global = {
      brewfile = true;
      # lockfiles = true;
    };

    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "zap";
    };

    # Applications to install from Mac App Store using mas.
    # You need to install all these Apps manually first so that your apple account have records for them.
    # otherwise Apple Store will refuse to install them.
    # For details, see https://github.com/mas-cli/mas
    #
    # WARN: currently disabled due to excessive install time
    #
    # masApps = {
    #   Xcode = 497799835;
    # };
    brews = [
      "jupyterlab"
      "dnote"
      "mlx"
      "surreal"
      "docker-compose"
      # "cmdg"
      # "llm"
      # "llvm@18"
      # "python3"
      # "node"
      # "television"
    ];
    casks = [
      "anaconda"
      "zoom"
      "obs"
      "iina"
      "jordanbaird-ice"
      "google-chrome"
      "hammerspoon"
      "1password-cli"
      "beeper"
      "notunes"
      "intellij-idea"
      "floorp"
      "1password"
      "raycast"
      "spotify"
      "slack"
      "discord"
      "visual-studio-code"
      "tailscale"
      # "kindle"
      "steermouse"
      "rectangle"
      "steam"
      "google-drive"
      "sublime-text"
      "sublime-merge"
      "signal"
      "claude"
      "zed"
      "cursor"
      "backblaze"
      "mic-drop"
      "emacs"
      "aerospace"
      "karabiner-elements"
      "scapple"
      "omnigraffle"
      "omnifocus"
      "kitty"
      "ghostty"
      "miro"
      "syncthing"
      "ollama"
      "element"
      "obsidian"
      "sengi"
      "stashpad"
      "orion"
      "arc"
      "chatgpt"
      "blurred"
      "docker"
      "google-chrome"
      "google-chrome@canary"
      "activitywatch"
      "timing"

      # "moonlight"

      # "firefox"
      # "grain-lang/tap/grain"
    ];
    taps = [
      "nikitabobko/aerospace"
      "homebrew/services"
      "dnote/dnote"
      "cutzenfriend/homebrew-cmdg"
      "surrealdb/surreal"
    ];
  };
}
