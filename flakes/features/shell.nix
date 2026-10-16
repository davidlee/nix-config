# Desktop shells, in projection order (DEC-026). Shape: README § Feature tree.
# A shell draws the bar, launcher and notifications inside a compositor session.
[
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
]
