{ hostname, username, pkgs, ... }: {

  environment.systemPackages = with pkgs; [
    git
    zsh
  ];
  
  system = {
    primaryUser = "davidlee";

    # so we do not need to logout and login again to make the changes take effect.
    # FIXME commented out to see if we don't need it / whether it's contributing to the issue with mouse natural scrolling 
    # activationScripts.postActivation.text = ''
    #   /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    # '';

    defaults = {  
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        "com.apple.swipescrolldirection" = false; # natural scrolling isn't
      };

      dock = {
        autohide = true;
      };

      finder = {
        AppleShowAllExtensions = true;
        _FXShowPosixPathInTitle = true;
      };
    };

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
