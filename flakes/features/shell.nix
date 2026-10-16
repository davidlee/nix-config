# Desktop shells, in projection order (DEC-026). Shape: README § Feature tree.
# A shell draws the bar, launcher and notifications inside a compositor session.
{lib, ...}: [
  {
    name = "noctalia";
    nixos = {
      pkgs,
      inputs,
      ...
    }: {
      environment.systemPackages = [
        inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };
  }

  # Walker launcher, with its elephant backend. The HM module, not the NixOS one:
  # only this one provides `runAsService` (a systemd user unit).
  {
    name = "walker";
    platforms = lib.platforms.linux;
    homeManager = {inputs, ...}: {
      imports = [inputs.walker.homeManagerModules.default];

      programs.walker = {
        enable = true;
        runAsService = true;
        # theme.name = "noctalia";
      };
    };
  }
]
