{
  # config,
  pkgs,
  # username,
  # lib,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    cosmic-settings
    cosmic-files
    cosmic-comp
    cosmic-ext-tweaks
    cosmic-edit
    cosmic-applets
    cosmic-bg
    cosmic-icons
    cosmic-idle
    cosmic-term
    cosmic-tasks
    cosmic-settings
    cosmic-session
  ];

  services = {
    desktopManager = {
      cosmic = {
        enable = true;
      };
    };
    # displayManager.cosmic-greeter.enable = true;
  };
}
