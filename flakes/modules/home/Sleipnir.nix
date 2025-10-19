_: {
  flake.homeModules.Sleipnir = {
    username,
    self,
    ...
  }: {
    imports = with self; [
      homeModules.nvim-plugins
      homeModules.nvim
      homeModules.zsh
      homeModules.programs
      # homeModules.break-remind
    ];

    home = {
      inherit username;
      homeDirectory = "/home/${username}";
      stateVersion = "24.11";
    };

    programs.home-manager.enable = true;

    services = {
      systembus-notify.enable = true; # notify-send from systemd
      mpris-proxy.enable = true;
    };
  };
}
