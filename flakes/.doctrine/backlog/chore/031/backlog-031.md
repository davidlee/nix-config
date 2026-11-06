# CHR-031: Audit capsule-tools across project flakes and update the fleet targets

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

DEC-128: `dev-tools` carries no Doctrine; a room gets it from `capsule-tools`.
Audit every project with a fleet target, and for each:

1. Does its room need Doctrine? If so, export `capsule-tools` (its tool list plus
   Doctrine), as `~/dev/doctrine/flake.nix` and `~/dev/satan/flake.nix` do.
2. Set `toolsPackage = "capsule-tools"` in `/srv/fleet/targets/<repo>.nix` and
   re-lock fleet.
3. Only then drop Doctrine from `dev-tools` (DEC-112's order).

Known, 2026-11-06:

- satan: done. `capsule-tools` committed (satan e399fae), and `targets/satan.nix`
  takes it. Check fleet's lock holds that satan.
- malebolge, panopticon: Doctrine is in `dev-tools`.
- screwtape, www: read the flake; a grep is not enough.

SPEC-003 takes the rule through REV-017.

Related: CHR-030, DEC-112, DEC-128.

## Audit, 2026-11-06

Measured: the build closure of each target's `dev-tools` at fleet's locked revs
(fleet HEAD 384c141), via `builtins.getFlake "git+file:///srv/fleet"`. A path ref
fails on `.vm/capsule/capsule.sock`.

satan is done: fleet locks e399fae68.

Doctrine in `dev-tools`, breaking DEC-128:

| repo | at fleet's lock | source | lock lag |
|---|---|---|---|
| malebolge | 0.46.10 | `flake.nix:36-39` | 28 commits |
| panopticon | 0.46.10 | `flake.nix:161` | 2 commits |
| emacs-config | 0.48.1 | `flake.nix:71`, not in the known list or in CHR-030 | 55 commits |

Clean `dev-tools`: goad, nix-config, notes, oubliette, resume, retrograde,
satan-attrd, smut, www.

- screwtape: `dev-tools` is clean at HEAD, but fleet locks d705f5b, before db60994
  added it, so the target's `null` and its comment are true of the lock only.
  Doctrine is in its forms (`flake.nix:70`) and devshell (`:102`), which DEC-128
  also excludes.
- www: no Doctrine input; the `dn` command runs whatever is on PATH.
- oubliette: `mkfleet.nix:2045` puts Doctrine in the devshell every mkFleet consumer
  gets. Not in `dev-tools`, so no shadowing, but it is in tension with DEC-128's
  "the project's own devshell carries no Doctrine".

What a room uses Doctrine for: malebolge's runner runs `doctrine prompt resolve
--role orchestrator` in a clone with `.doctrine/`
(`src/runner/project-context.ts:51,105`). If that fails the job goes on without the
boot and reports `context_degraded` (`:142`). So a missing Doctrine degrades a job;
it does not stop one.

13 targets track `.doctrine/` with the boot ignored. 5 have Doctrine in the room
(doctrine, satan, emacs-config, malebolge, panopticon); 8 do not (deck_of_dwarf,
oubliette, quotient, resume, satan-attrd, screwtape, smut, www). Not checked: which
repos the runner is configured to take jobs in. The other 7 targets track no
`.doctrine/` at the clone root, so the runner skips them (nix-config's is under
`flakes/`).

Fleet inputs: satan and emacs-config follow fleet's `doctrine`; malebolge and
panopticon do not, which is why they sit at 0.46.10.

## Outcome, 2026-11-06

Operator: runs ahead of CHR-030; malebolge, panopticon and emacs-config keep Doctrine
in the room; the other eight go to CHR-032; Doctrine leaves every project devshell.

| repo | capsule-tools | dev-tools drops doctrine |
|---|---|---|
| malebolge | bbe1e04 | fc35624 |
| panopticon | 3316bf7 | 7860922 |
| emacs-config | 29deb71 | 2b616d0 |

Fleet 7dbf253: the three targets take `capsule-tools`, malebolge and panopticon follow
fleet's `doctrine`, and the three inputs lock at the capsule-tools commits. Only those
inputs moved. Each room image and `capsule-tools` closure has 0.48.1; at each repo's
HEAD, `dev-tools` and the devshell have none. `capsule-tools` was built through fleet;
no room was rebuilt or booted, and no repo's `just check` was run (flake edits only).

screwtape 1dec790 drops Doctrine from its devshell; its forms keep it. Not pushed.

The devshell `mkFleet` gives every consumer (`mkfleet.nix:2045`) stays: left for now
on the operator's "maybe actually not mkFleet". DEC-128 does not record that exception.
