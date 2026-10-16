# Virtual camera (from kernel.nix).
{pkgs, ...}: {
  boot = {
    kernelModules = ["v4l2loopback"];
    extraModulePackages = [pkgs.linuxPackages_latest.v4l2loopback.out];
    extraModprobeConfig = ''
      # exclusive_caps: Skype, Zoom, Teams etc. will only show device when actually streaming
      # card_label: Name of virtual camera, how it'll show up in Skype, Zoom, Teams
      # https://github.com/umlaeute/v4l2loopback
      options v4l2loopback exclusive_caps=1 card_label="Virtual Camera"
    '';
  };
}
