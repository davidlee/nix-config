# Virtual camera (from kernel.nix).
{config, ...}: let
  # On kernel 7.3 the module's install leaves depmod's index (modules.dep, …)
  # in its output, which collides with the kernel's in the modules tree; that
  # tree builds its own index (ISS-017, probe in workarounds/default.nix).
  v4l2loopback = config.boot.kernelPackages.v4l2loopback.overrideAttrs (old: {
    postInstall =
      (old.postInstall or "")
      + ''
        rm -f $out/lib/modules/*/modules.*
      '';
  });
in {
  boot = {
    kernelModules = ["v4l2loopback"];
    extraModulePackages = [v4l2loopback.out];
    extraModprobeConfig = ''
      # exclusive_caps: Skype, Zoom, Teams etc. will only show device when actually streaming
      # card_label: Name of virtual camera, how it'll show up in Skype, Zoom, Teams
      # https://github.com/umlaeute/v4l2loopback
      options v4l2loopback exclusive_caps=1 card_label="Virtual Camera"
    '';
  };
}
