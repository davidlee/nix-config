_: {
  flake.nixosModules.pipewire = {pkgs, ...}: {
    # rtkit (optional, recommended) allows Pipewire to use the realtime scheduler for increased performance.
    security.rtkit.enable = true;
    services = {
      pipewire = {
        enable = true; # if not already enabled
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        #jack.enable = true;
      };
    }; # services
    environment.systemPackages = [pkgs.cava];
  };
}
