{pkgs, ...}: {
  boot = {
    #
    # initrd
    #
    initrd = {
      kernelModules = [];
      verbose = true;
    };

    #
    # Kernel modules
    #
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [
      "snd-seq"
      "snd-rawmidi"
      "snd-aloop"
      "v4l2loopback"
    ];

    kernelPatches = [
      {
        name = "Rust Support";
        patch = null;
        features = {
          rust = true;
        };
      }
    ];

    extraModulePackages = [pkgs.linuxPackages_latest.v4l2loopback.out];
    extraModprobeConfig = ''
      # exclusive_caps: Skype, Zoom, Teams etc. will only show device when actually streaming
      # card_label: Name of virtual camera, how it'll show up in Skype, Zoom, Teams
      # https://github.com/umlaeute/v4l2loopback
      options v4l2loopback exclusive_caps=1 card_label="Virtual Camera"
    '';

    blacklistedKernelModules = [
      "ucsi_ccg"
      "vc032x"
      "gspca_vc032x"
    ];
  }; # /boot
}
