{
  pkgs,
  username,
  lib,
  config,
  inputs,
  ...
}: let
  inherit (import ../../hosts/nixos/variables.nix) gitUsername;
in {
  options = {users.enable = lib.mkEnableOption "Enables users module";};

  config = lib.mkIf config.users.enable {
    # TODO investigate; this may not be required if hashedPassword is set?
    users.mutableUsers = true; 

    users.users = {
      "${username}" = {
        homeMode = "755";
        isNormalUser = true;
        description = "David Lee";
        hashedPassword = "$y$j9T$M1O771cWWQrbfPt1rH6Q91$BdWZzN5nF6AHnnPt.WVV5N6WTnuho7xJFT8OW14PrJA";
        extraGroups = [ "networkmanager" "wheel" "root" "dev" "video" ];
        home = "/home/david/";
        shell = pkgs.zsh;
        # ignoreShellProgramCheck = true;
        packages = with pkgs; [
          inputs.home-manager.packages.${pkgs.system}.default
          pkgs.hello
        ];
      };
    };

    environment = {
      variables = {
        NIXOS = "true";
        # NIXOS_VERSION = "25.05";
        EDITOR = "nvim";
        VISUAL = "nvim";
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
