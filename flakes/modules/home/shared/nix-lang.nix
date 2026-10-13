{pkgs,...}: {
# environment.packages = with pkgs; [statix deadnix];
programs.statix.enable = true;
programs.deadnix.enable = true;
}
