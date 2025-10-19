_: {
  flake.nixosModules.pipewire = {pkgs, ...}: {
    # rtkit (optional, recommended) allows Pipewire to use the realtime scheduler for increased performance.
    security.rtkit.enable = true;
    services = {
      avahi.enable = true;
      pipewire = {
        enable = true; # if not already enabled
        audio.enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };
        pulse = {
          enable = true;
        };

        # Airplay compat
        raopOpenFirewall = true;
        extraConfig.pipewire = {
          "10-airplay" = {
            "context.modules" = [
              {
                name = "libpipewire-module-raop-discover";
                # increase the buffer size if you get dropouts/glitches
                # args = {
                #   "raop.latency.ms" = 500;
                # };
              }
            ];
          };
        };

        # extra bt protocols
        wireplumber.extraConfig."10-bluez" = {
          "monitor.bluez.properties" = {
            "bluez5.enable-sbc-xq" = true;
            "bluez5.enable-msbc" = true;
            "bluez5.enable-hw-volume" = true;
            "bluez5.roles" = [
              "hsp_hs"
              "hsp_ag"
              "hfp_hf"
              "hfp_ag"
            ];
          };
        };
        #jack.enable = true;
      };

      pulseaudio = {
        support32Bit = true;
        package = pkgs.pulseaudioFull;
        extraConfig = "load-module module-combine-sink";
        configFile = pkgs.writeText "default.pa" ''
          load-module module-bluetooth-policy
          load-module module-bluetooth-discover
          ## module fails to load with
          ##   module-bluez5-device.c: Failed to get device path from module arguments
          ##   module.c: Failed to load module "module-bluez5-device" (argument: ""): initialization failed.
          # load-module module-bluez5-device
          # load-module module-bluez5-discover
        '';
      };
    }; # services
  };
}
