# The home base's direnv (DEC-031/042); everything else is a feature.
_: {
  programs = {
    direnv = {
      enable = true;
      silent = true;
      nix-direnv.enable = true;
      # Project helpers (`use agents_dev`, `use flake_local`) live in
      # ~/flakes/envrc/agents.sh, which each .envrc sources (IMP-047).
    };
  };
}
