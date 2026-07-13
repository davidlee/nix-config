_: {
  services.journald.extraConfig = ''
    RuntimeMaxUse=512M
    MaxRetentionSec=14days
  '';
}
