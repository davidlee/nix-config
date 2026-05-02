_: {
  flake.nixosModules.printing = {pkgs, ...}: {
    services.printing = {
      enable = true;
      drivers = with pkgs; [
        brlaser # Brother HL-L2445DW
        gutenprint # broad Canon/inkjet support
        gutenprintBin
      ];
    };

    environment.systemPackages = with pkgs; [
      system-config-printer
    ];
  };
}
