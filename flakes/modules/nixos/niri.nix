_: {
  flake.nixosModules.niri = {pkgs, ...}: {
    programs = {
      niri = {
        enable = true;
        useNautilus = true;
      };
      dms-shell = {
        enable = true;
        # plugins
        # enableDynamicTheming = true;
        # enableSystemMonitoring = true;
      };
    }; # programs
    environment.systemPackages = with pkgs; [niriswitcher xwayland-satellite];
  };
}
