{pkgs, ...}: {
  security = {
    pam.services = {
      greetd.enableGnomeKeyring = true;
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

    dbus.packages = [pkgs.gcr_4];
  }; # services
}
