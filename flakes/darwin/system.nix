{ hostname, username, pkgs, ... }: {

  environment.systemPackages = with pkgs; [
    git
    zsh
  ];
  
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

    # configurationRevision = self.rev or self.dirtyRev or null;

    stateVersion = 6;
    
    defaults.smb.NetBIOSName = hostname;
  };
  security.pam.services.sudo_local.touchIdAuth = true;

  networking = {
    hostName = hostname;
    computerName = hostname;
  };

  #
  # users
  # 

  users.users."${username}" = {
    home = "/Users/${username}";
    description = username;
  };

  nix.settings.trusted-users = [ username ];
}
