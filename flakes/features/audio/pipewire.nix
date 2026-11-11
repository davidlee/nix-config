{
  name = "pipewire";
  nixos = {
    pkgs,
    username,
    ...
  }: {
    environment.systemPackages = with pkgs; [
      ## audio / music
      pavucontrol
      pulseaudio # client tools only (pactl, paplay); daemon stays off, pipewire-pulse serves
      alsa-utils
      ncpamixer
    ];
    # rtkit (optional, recommended) allows Pipewire to use the realtime scheduler for increased performance.
    security.rtkit.enable = true;
    boot.kernelModules = ["snd-aloop"];
    users.users.${username}.extraGroups = ["audio"];
    services = {
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
        # JACK: the audio.daw feature (pw-jack per process), not jack.enable.
      };
    }; # services
  };
}
