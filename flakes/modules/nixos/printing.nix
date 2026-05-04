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

    # static resolution for printers — CUPS' ipp backend
    # can't resolve .local via avahi in its sandbox
    networking.extraHosts = ''
      192.168.0.30 BRWC8A3E8DADA55.local
    '';

    environment.systemPackages = with pkgs; [
      system-config-printer
    ];
  };
}
