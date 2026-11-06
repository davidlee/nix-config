# CHR-033: Prove Doctrine in a rebuilt room: move the host's fleet lock and boot one

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

CHR-032 moved fleet's targets to `capsule-tools` (fleet 37992dd) and proved it by closure:
each `capsule-tools` and `image-<target>` holds Doctrine 0.48.1. No room has been rebuilt
or booted, so `session <repo> -- doctrine --version` is still unproven in a room.

Delivery, from oubliette's README (read, not run):

```
~/flakes: nix flake update fleet ─► host switch ─► just refresh-build <room> (microvm -u) ─► capsule <room> start
```

After a switch `current` still names the old image until `microvm -u` moves it. Re-locking
also pulled each repo's other commits into its room.

Check too: the runner's `doctrine prompt resolve` no longer reports `context_degraded`
in a repo with `.doctrine/` at its root. nix-config's is under `flakes/`, so the runner
still skips it.

Related: CHR-032, DEC-130.
