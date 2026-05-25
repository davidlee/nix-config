_: {
  flake.nixosModules.maintenance = _: {
    services.journald.extraConfig = ''
      RuntimeMaxUse=512M
      MaxRetentionSec=14days
    '';
  };
}
