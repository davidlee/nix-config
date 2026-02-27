_: {
  flake.homeModules.Sleipnir = {
    username,
    self,
    ...
  }: {
    imports = with self; [
      # shared
      homeModules.nvim-plugins
      homeModules.nvim
      homeModules.zsh
      homeModules.programs
      # homeModules.break-remind

      # nixos
      homeModules.sway
      homeModules.games
      homeModules.wayland
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
  };
}
