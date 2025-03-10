{
  pkgs,
  username,
  lib,
  config,
  inputs,
  ...
}: {
  options = {users.enable = lib.mkEnableOption "Enables users module";};

  config = lib.mkIf config.users.enable {
    security.rtkit.enable = true;
    security.polkit.enable = true;
    security.sudo.wheelNeedsPassword = false; # WARN 

    users.mutableUsers = true; # can do without password being clobbered

    users.users = {
      "${username}" = {
        homeMode = "755";
        isNormalUser = true;
        description = "David Lee";
        extraGroups = [ "networkmanager" "wheel" "root" "dev" "video" "docker" "caddy" "libvirtd" "jackaudio"];
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
        XCURSOR_SIZE = 24;
        # NIXOS_OZONE_WL = 1;
        ELECTRON_OZONE_PLATFORM_HINT = "x11";
      };
      pathsToLink = [ "/share/zsh" ]; # for autocompletion
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
  };
}
