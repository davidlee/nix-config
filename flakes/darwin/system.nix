{ pkgs, ... }: {
  system = {
    activationScripts.postUserActivation.text = ''
      # so we do not need to logout and login again to make the changes take effect.
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';

    defaults = {  
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
      };

      dock = {
        autohide = true;
      };

      finder = {
        AppleShowAllExtensions = true;
        _FXShowPosixPathInTitle = true;
      };
    };
  };

  security.pam.enableSudoTouchIdAuth = true;
  programs.zsh.enable = true;
}
