# ISS-006: flake.lock pins agents (and dev inputs) as local paths; update recipes write overrides into the lock

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

## Observation

`flake.lock` locks `agents` as `{type = path; path = /home/david/flakes/agents}`
(also `panopticon`, `satan-attrd`, `satan-patcher` as `/home/david/dev/...`),
while `flake.nix` declares `agents` from GitHub and `justfile:8` claims it is
"locked from GitHub (portable)". Found in SL-004 design review (RV-009 F-1).

Likely cause: `update-system` / `update-home` / `update-local` run
`nix flake update … {{system_override}}`; `--override-input` on a lock-writing
command records the override in the lock.

## Impact

Any machine without those paths (the Mac, a fresh clone) cannot fetch the
input. SL-004 works around it by overriding `agents` in every Mac evaluation;
the lock itself stays non-portable.

## Fix direction

Drop the overrides from lock-writing recipes, re-lock the affected inputs from
their declared URLs, and check drvs identity (path vs GitHub source of the same
tree should give the same store content).
