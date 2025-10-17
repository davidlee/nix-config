_: {
  flake.nixosModules.bluetooth = {pkgs, ...}: {
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
    ];
  };
}
