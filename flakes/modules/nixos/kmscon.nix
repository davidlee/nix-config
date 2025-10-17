_: {
  flake.nixosModules.kmscon = {pkgs, ...}: {
    services = {
      kmscon = {
        enable = true;
        hwRender = true;
        fonts = [
          {
            name = "JetBrainsMono Nerd Font";
            package = pkgs.nerd-fonts.jetbrains-mono;
          }
        ];
      };
    };
  };
}
