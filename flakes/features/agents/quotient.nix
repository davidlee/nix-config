# agents.quotient: the quotient MCP server on PATH, and the machine-default
# forms at the paths ~/.config/quotient/policy.json names (IMP-048). The
# forms are ./quotient/family.nix; the policy itself stays a dotfile.
# Listed in ../agents.nix. Linux only: the forms are bubblewrap jails, and
# they reach models through the gateway's `pi` key.
{lib, ...}: {
  name = "quotient";
  requires = ["agents.gateway"];
  platforms = lib.platforms.linux;
  homeManager = {
    inputs,
    pkgs,
    ...
  }: let
    family = import ./quotient/family.nix {inherit inputs pkgs;};
  in {
    home.packages = [inputs.quotient.packages.${pkgs.stdenv.hostPlatform.system}.default];
    xdg.stateFile = {
      "quotient/forms/read".source = family.read;
      "quotient/forms/write".source = family.write;
    };
  };
}
