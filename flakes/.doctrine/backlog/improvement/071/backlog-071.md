# IMP-071: just upgrade: push, re-lock in dependency order, verify, switch

Updating was too many hand steps, in an order that is easy to get wrong: ISS-016
showed `agents/flake.lock` does not reach a build until it is pushed and the root
lock takes it, because the root lock's copy of agents' inputs beats the
`--override-input agents path:…` override. `update-all` was a bare
`nix flake update`, which could not do this.

`bin/upgrade [--keep-nixpkgs]`, with recipes `upgrade` and `upgrade-keep-nixpkgs`.
Agreed with the user 2026-11-08. It replaced `update-all`, `push-local` and
`everything`. Order and refusals: README § Upgrade and the script's header.

Choices: refuses dirty flake.nix/flake.lock in the chain; pushes whatever is
committed, public repos included; reminds of `just update-room`, never restarts
the room; ends with `just sync-room`, whose failure only warns.
`bin/dev-checkouts repos` is the one repo list.

Not covered: an uncached codex at llm-agents HEAD builds from source (IMP-050).

Done when: `just upgrade` has run once on Sleipnir, landing ISS-016.
