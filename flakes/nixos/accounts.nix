{
  pkgs,
  username,
  inputs,
  ...
}: {
  security = {
    rtkit.enable = true;
    polkit.enable = true;

    sudo = {
      enable = true;
      extraRules = [
        {
          groups = ["wheel"];
          commands = [
            {
              command = "${pkgs.nix}/bin/rtcwake *";
              options = ["NOPASSWD" "SETENV"];
            }
          ];
        }
        {
          groups = ["wheel"];
          commands = ["ALL"];
        }
      ];
    };

    pam.loginLimits = [
      # allow any user prog to request realtime priority
      {
        domain = "@users";
        item = "rtprio";
        type = "-";
        value = 1;
      }
    ];
  };

  users.mutableUsers = true; # can do without password being clobbered

  services = {
    gnome.gcr-ssh-agent.enable = true;
  };

  users.users = {
    "${username}" = {
      homeMode = "755";
      isNormalUser = true;
      description = "David Lee";
      extraGroups = ["networkmanager" "wheel" "root" "dev" "video" "docker" "caddy" "libvirtd" "jackaudio" "audio" "gamemode" "input"];
      home = "/home/${username}";
      shell = pkgs.zsh;
      packages = [
        inputs.home-manager.packages.${pkgs.system}.default
      ];
    };
  };
}
