# Hardware features, in projection order. Shape: README § Feature tree.
_: [
  {
    name = "openrgb";
    nixos = {pkgs, ...}: {
      services = {
        hardware.openrgb.enable = true;
        udev.packages = [pkgs.openrgb-with-all-plugins];
      };
    };
  }

  {
    name = "bluetooth";
    nixos = {pkgs, ...}: {
      # it's amazing bluetooth _ever_ works
      hardware = {
        bluetooth = {
          enable = true;
          powerOnBoot = true;
          settings = {
            General = {
              Experimental = true; # battery level
              JustWorksRepairing = "always";
              FastConnectable = true;
              # Class = "0x00100";
              Privacy = "device";
            };
          };
        };
      };

      services = {
        blueman.enable = true;
      };

      environment.systemPackages = with pkgs; [
        # bluetooth
        blueman
        bluetui
        bluetuith
        bluez
      ];
    };
  }

  {
    name = "qmk";
    nixos = {pkgs, ...}: {
      hardware = {
        # allow non-root write access to firmware
        keyboard.qmk.enable = true;
      };

      environment.systemPackages = with pkgs; [
        ## keyboard firmware
        qmk-udev-rules
        dfu-util
        qmk
        dtc
      ];
    };
  }

  {
    name = "tablet";
    nixos = _: {
      hardware = {
        opentabletdriver.enable = true;
        # Required by OpenTabletDriver
        uinput.enable = true;
      };
      boot.kernelModules = ["uinput"];
    };
  }

  {
    name = "logitech";
    nixos = _: {
      hardware.logitech.wireless.enable = true;
    };
  }
]
