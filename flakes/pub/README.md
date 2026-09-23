# pub (deprecated)

Renamed to [`../agents`](../agents/README.md). This flake only re-exports it so
existing `github:davidlee/nix-config?dir=flakes/pub` inputs keep working.
Migrate by pointing the input at `?dir=flakes/agents` (renaming it `agents` is
optional).
