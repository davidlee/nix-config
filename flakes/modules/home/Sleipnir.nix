_: {
  flake.homeModules.Sleipnir = {
    username,
    pkgs,
    self,
    ...
  }: {
    imports = with self; [
      homeModules.nvim-plugins
      homeModules.nvim
      homeModules.zsh
      homeModules.programs
      homeModules.break-remind
    ];

    home = {
      inherit username;
      homeDirectory = "/home/${username}";
      stateVersion = "24.11";
    };

    services.systembus-notify.enable = true; # notify-send from systemd

    programs.home-manager.enable = true;
  };
}
