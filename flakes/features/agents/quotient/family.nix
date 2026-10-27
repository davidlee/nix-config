# The machine-default quotient form family (IMP-048): the forms the host
# policy names for every root without an approval of its own. Generic by
# rule: the lib's posture and base tools, and no project's env or toolchain;
# a project that needs either approves its own form (`quotient allow`).
# Shared by the agents.quotient feature and checks.quotient-forms.
{
  inputs,
  pkgs,
}: let
  jailLib = inputs.agents.lib.${pkgs.stdenv.hostPlatform.system}.mkJailedAgents {};
in
  jailLib.quotientFormFamily {
    inherit (inputs) quotient;
    packages = jailLib.commonPkgs ++ [pkgs.just];
  }
