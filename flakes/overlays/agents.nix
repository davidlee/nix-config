# Inject the llm-agents CLIs (codex, claude, gemini, opencode, pi, crush)
# into nixpkgs under their short names, sourced from agents' agentsOverlay so
# the dev-flake path and the system override share one definition. llm-agents
# keeps its own nixpkgs pin (numtide binary cache), not `follows`.
#
# Takes `system` explicitly rather than reading `prev.system`, which would
# force the target pkgs fixpoint from inside the overlay, recursing through
# stdenv bootstrap. The agent packages come from agents' own pkgs and are
# independent of final/prev. Being a function of system, it is not a valid
# `overlays.*` flake output, so flake.nix applies it directly.
{inputs}: system: inputs.agents.lib.${system}.agentsOverlay {}
