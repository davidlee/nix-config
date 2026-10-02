_: {
  homebrew = {
    enable = true;
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
      "d2"
      "git" # gitFull equivalent with svn support
    ];
    casks = [
      "google-chrome"
      "1password-cli"
      "notunes"
      "1password"
      "raycast"
      "spotify"
      "slack"
      "tailscale-app"
      "steermouse"
      "rectangle"
      "google-drive"
      "sublime-text"
      "sublime-merge"
      "signal"
      "claude"
      "zed"
      "karabiner-elements"
      "scapple"
      "omnigraffle"
      "kitty"
      "ghostty"
      # "syncthing"
      # "element"
      "obsidian"
      "orion"
      "docker-desktop"
      "google-chrome@canary"
      "nushell"
    ];
  };
}
