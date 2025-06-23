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
            # {
            #   command = "${pkgs.nix}/bin/nixos-rebuild";
            #   options = ["NOPASSWD"];
            # }
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

  # TODO remove immutable users
  users.mutableUsers = true; # can do without password being clobbered

  # programs = {
  #   ssh = {
  #     startAgent = false;
  #     enableAskPassword = true;
  #   };
  #
  #   # cant' have this and ssh-agent both enabled
  #   gnupg.agent = {
  #     enable = false;
  #     enableSSHSupport = true;
  #   };
  # };

  services = {
    gnome.gcr-ssh-agent.enable = true;
  };

  users.users = {
    "${username}" = {
      homeMode = "755";
      isNormalUser = true;
      description = "David Lee";
      extraGroups = ["networkmanager" "wheel" "root" "dev" "video" "docker" "caddy" "libvirtd" "jackaudio" "audio" "gamemode"];
      home = "/home/${username}";
      shell = pkgs.zsh;
      packages = [
        inputs.home-manager.packages.${pkgs.system}.default
      ];
    };
  };

  environment = {
    variables = {
      NIXOS = "true";
      VISUAL = "hx";
      SSH_ASKPASS_REQUIRE = "prefer";
    };
    pathsToLink = ["/share/zsh"]; # for autocompletion
  };

  # i18n / l10n
  #
  time.timeZone = "Australia/Melbourne";

  i18n.defaultLocale = "en_AU.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  };
}
