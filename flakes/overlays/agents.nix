# Inject the llm-agents CLIs (codex, claude, gemini, opencode, pi, crush)
# into nixpkgs under their short names, sourced from pub's agentsOverlay so
# the dev-flake path and the system override share one definition. llm-agents
# keeps its own nixpkgs pin (numtide binary cache), not `follows`.
#
# System is hardcoded (x86_64-linux — the only host this overlay is applied
# to). Reading `prev.system` instead would force the target pkgs fixpoint
# from inside the overlay, recursing through stdenv bootstrap. The agent
# packages come from pub's own pkgs and are independent of final/prev.
{inputs}: inputs.pub.lib.x86_64-linux.agentsOverlay {inherit (inputs) llm-agents;}
