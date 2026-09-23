# Inject the llm-agents CLIs (codex, claude, gemini, opencode, pi, crush)
# into nixpkgs under their short names, sourced from agents' agentsOverlay so
# the dev-flake path and the system override share one definition. llm-agents
# keeps its own nixpkgs pin (numtide binary cache), not `follows`.
#
# System is hardcoded (x86_64-linux — the only host this overlay is applied
# to). Reading `prev.system` instead would force the target pkgs fixpoint
# from inside the overlay, recursing through stdenv bootstrap. The agent
# packages come from agents' own pkgs and are independent of final/prev.
{inputs}: inputs.agents.lib.x86_64-linux.agentsOverlay {}
