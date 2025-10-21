_: {
  flake.nixosModules.kanshi = {pkgs, ...}: {
    # kanshi systemd service - monitor hot-swapping
    # has a startup script in sway extraConfig
    systemd.user.services.kanshi = {
      description = "kanshi daemon";
      environment = {
        WAYLAND_DISPLAY = "wayland-1";
        DISPLAY = ":0";
      };
      serviceConfig = {
        Type = "simple";
        ExecStart = ''${pkgs.kanshi}/bin/kanshi -c kanshi_config_file'';
      };
    };
  };
}
