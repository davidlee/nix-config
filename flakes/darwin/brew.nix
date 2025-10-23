_: {
  homebrew = {
    enable = true;
    caskArgs.no_quarantine = true;
    global = {
      brewfile = true;
      # lockfiles = true;
    };

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      # cleanup = "zap";
    };

    brews = [
      "jupyterlab"
      "dnote"
      "mlx"
      "surreal"
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
