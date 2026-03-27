_: {
  # this also depends on v4l2loopback in boot
  flake.homeModules.obs-studio = {pkgs, ...}: {
    programs.obs-studio = {
      enable = true;
    };
    programs.obs-studio.plugins = [pkgs.obs-studio-plugins.wlrobs];
  };
}
