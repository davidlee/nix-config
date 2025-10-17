_: {
  flake.nixosModules.x11 = {
    pkgs,
    username,
    ...
  }: {
    services = {
      # have X11 available, but not running by default
      xserver = {
        enable = true;
        displayManager = {
          startx.enable = true;
          sessionCommands = ''
            export SSH_AUTH_SOCK
          '';
        };

        desktopManager = {
          # cinnamon.enable = true;
          # mate.enable = true;
        };
      }; # services
    };
  };
}
