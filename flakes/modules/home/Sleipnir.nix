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
      homeModules.helix
      homeModules.zsh
      homeModules.programs

      # nixos
      homeModules.media
      homeModules.terminals
      homeModules.zed-editor
      homeModules.sway
      homeModules.games
      homeModules.wayland
      homeModules.ai
      homeModules.browsers
      homeModules.editors
      homeModules.graphics
      homeModules.office
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
