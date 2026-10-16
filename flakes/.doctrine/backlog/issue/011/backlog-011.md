# ISS-011: flake.nix oubliette follows name inputs oubliette's HEAD dropped (target, goad-walk)

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

`flake.nix:132-133` declares `oubliette.inputs.target.follows` and
`goad-walk.follows`. The locked oubliette (61701fe) has both inputs. The local
checkout's SL-004 work (oubliette 1284c5a, "no target is in its lock") removed
them, so every run with `dev_override` warns "input 'oubliette' has an override
for a non-existent input 'target'" (and 'goad-walk').

Fix: once oubliette is pushed and `just update-local` re-locks it, delete the
two follows lines and the `target` comment above them (flake.nix:116-133).
Then check that `just gate` prints neither warning.

Found by RV-021 F-5 (SL-009 audit).
