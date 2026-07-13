{username, ...}: {
  imports = [
    ../../profiles/linux-desktop.nix

    # machine-specific
    ../../modules/home/linux/sleipnir-doctor.nix
    ../../modules/home/linux/satan.nix
    ../../modules/home/linux/satan-patcher.nix
    ../../modules/home/linux/satan-attrd.nix
    ../../modules/home/linux/behaviour.nix

    ../../modules/home/shared/cli.nix
  ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;

  services = {
    systembus-notify.enable = true; # notify-send from systemd
    # mpris-proxy.enable = true;
  };
}
