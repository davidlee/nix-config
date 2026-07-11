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
        enableDynamicTheming = true;
        enableCalendarEvents = true;
        enableAudioWavelength = true;
        enableClipboardPaste = true;

        systemd.enable = true;
      };
    }; # programs
    environment.systemPackages = with pkgs; [niriswitcher xwayland-satellite];
  };
}
