_: {
  services.journald.settings.Journal = {
    RuntimeMaxUse = "512M";
    MaxRetentionSec = "14days";
  };
}
