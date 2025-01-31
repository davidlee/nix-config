{
  pkgs,
  username,
  lib,
  config,
  inputs,
  ...
}: let
  inherit (import ../../hosts/magic/variables.nix) gitUsername;
in {
  options = {users.enable = lib.mkEnableOption "Enables users module";};

  config = lib.mkIf config.users.enable {
     users.users = {
       "${username}" = {
         homeMode = "755";
         isNormalUser = true;
         # description = "${gitUsername}";
         description = "David Lee";
         # hashedPassword = "$6$hLxz1nh01PVcUQ6e$4o6tYrRxbRQQFRN3NSUMkPuwdRpOhNdp1s07TAYr2shcbdQUkYurHyk8Xp8FvjVPwr60N4NSPDmwUr6Nd5FD9.";
         # extraGroups = ["networkmanager" "wheel" "libvirtd" "scanner" "lp" "root" "jr"];
         extraGroups = [ "networkmanager" "wheel" ];
         home = "/home/david/";
         shell = pkgs.zsh;
         # ignoreShellProgramCheck = true;
         # packages = with pkgs; [tealdeer zoxide mcfly tokei inputs.home-manager.packages.${pkgs.system}.default];
         # packages = with pkgs; [
         #   #  thunderbird
         # ];
       };
     };

    environment = {
      variables = {
        NIXOS = "true";
        # NIXOS_VERSION = "25.05";
        EDITOR = "nvim";
        VISUAL = "nvim";
      };
      pathsToLink = [ "/share/zsh" ]; # for autocompletions ... I think?
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
