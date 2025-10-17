_: {
  flake.nixosModules.keyring = {pkgs, ...}: {
    security = {
      polkit.enable = true;
      pam.services = {
        greedt = {
          enableGnomeKeyring = true;
        };
        greetd-password = {
          enable = true;
          enableGnomeKeyring = true;
        };
        login = {
          enableGnomeKeyring = true;
        };
      };
    };

    programs = {
      seahorse.enable = true;
    };

    services = {
      gnome = {
        gnome-keyring.enable = true;
        gcr-ssh-agent.enable = true;
      };

      dbus.packages = [pkgs.gcr];
    }; # services
  };
}
