{ pkgs, ... }: {
  #    https://daiderd.com/nix-darwin/manual/index.html#sec-options

  system = {
    # activationScripts are executed every time you boot the system or run `nixos-rebuild` / `darwin-rebuild`.
    activationScripts.postUserActivation.text = ''
      # activateSettings -u will reload the settings from the database and apply them to the current session,
      # so we do not need to logout and login again to make the changes take effect.
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';

    defaults = {  
      NSGlobalDomain = {
        # Dark mode
        # AppleInterfaceStyle = "Dark";
        
        # Show all file extensions
        AppleShowAllExtensions = true;

        # Automatically hide and show the menu bar
        _HIHideMenuBar = true;
      };

      dock = {
        # Automatically hide and show the Dock
        autohide = true;
        
        # Style options
        # orientation = "left";
        # show-recents = false;
      };

      finder = {
        AppleShowAllExtensions = true;
        _FXShowPosixPathInTitle = true;
      };
    };
  };

  # Add ability to used TouchID for sudo authentication
  security.pam.enableSudoTouchIdAuth = true;

  # Create /etc/zshrc that loads the nix-darwin environment.
  # this is required if you want to use darwin's default shell - zsh
  programs.zsh.enable = true;
  programs.zsh.enableFzfCompletion = true; 
  programs.zsh.enableSyntaxHighlighting = true;
}
