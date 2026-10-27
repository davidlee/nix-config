{
  description = "Deprecated alias for flakes/agents (jailed LLM agents)";

  # Kept so existing consumers of `?dir=flakes/pub` keep evaluating; migrate
  # them to `github:davidlee/nix-config?dir=flakes/agents`. Re-exports
  # everything. `nixpkgs` is declared only so consumers' existing
  # `pub.inputs.nixpkgs.follows` still reaches the real flake.
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agents = {
      url = "github:davidlee/nix-config?dir=flakes/agents";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {agents, ...}: {inherit (agents) lib checks packages;};
}
