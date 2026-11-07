# What the relay tests share: the library over fake agents, and over a bwrap
# that records its argv, so a launch is observable without namespaces.
{
  pkgs,
  jail-nix,
}: let
  system = pkgs.stdenv.hostPlatform.system;

  fakeAgent = name: pkgs.writeShellScriptBin name "exit 0";
  fakeAgents.packages.${system} = {
    pi = fakeAgent "pi";
    claude-code = fakeAgent "claude";
  };
  fakeBwrap = pkgs.writeShellScriptBin "bwrap" ''
    printf '%s\n' "$@" > bwrap-argv
  '';
  mkAgents = extra:
    import ./jailed-agents.nix ({
        inherit pkgs jail-nix;
        llm-agents = fakeAgents;
        zmx = fakeAgent "zmx";
        zmx-new = fakeAgent "zmx-new";
      }
      // extra);
in {
  agents = mkAgents {};
  fakeBwrapAgents = mkAgents {
    pkgs = pkgs.extend (_: _: {bubblewrap = fakeBwrap;});
  };
}
