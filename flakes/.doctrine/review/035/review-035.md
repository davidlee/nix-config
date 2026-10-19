# Review RV-035 — reconciliation of SL-016

Adversarial-review ledger. Structured findings live in the sister
ledger toml; this prose companion carries the reviewer's framing.

## Brief

<!-- Pre-reading + lines of attack: what this review is probing, the invariants
     it must hold the subject to, and where the bodies are likely buried. Seeded
     at `review new`; the reviewer fills it before raising findings. -->

Conformance audit of SL-016 (commits b08fe1f2, fc3ca4c8) against design.md
(locked r28), plan.toml and DEC-079, in the primary tree.

Lines of attack:

- The door file's schema: exactly ROOM_DOOR_KEYS + home under one [door]
  table (DEC-079), and the live file.
- Neutrality: runner config.toml store path, and the features / host-meta check
  drvs (the evalTests refactor).
- Divergences between the landed code and design sec-2..sec-6 (notes.md
  records two).
- Plan integrity: plan.toml edited mid-flight (PHASE-01 header repair, VT-1
  keywords).
- Conformance: `slice conformance` misattributes every path (ISS-005, the
  `flakes/` prefix); judged by inspection.
- POL-001: nothing secret rendered (the door names a key path, not key
  material).


## Synthesis

SL-016 delivered what it scoped. features/satan/room.nix holds the room facts
both doors share. runner.nix builds the runner's `[door]` from it, and its
config.toml store path is unchanged (`gkanmpxg…`), so the change is neutral
for the runner. It also renders ~/.config/malebolge/door.toml: one `[door]`
table with exactly ROOM_DOOR_KEYS + home, live after the user's home-switch.
checks.<system>.satan-room pins that schema (DEC-079), and a mutation
(a stray `ssh_config`) fails it. The evalTests refactor left the
features/host-meta drvs unchanged. `doctrine check gate` passes.

Divergences are all in the design text, not the code (F-1..F-3): the landed
evalTests signature, the red-step stub, statix's inherit form, and the
settled README condition. F-4 records the mid-phase plan edits, tolerated with
rationale. F-5 is the known ISS-005 attribution misfire.

Standing risks:
- ROOM_DOOR_KEYS is hand-copied from malebolge src/room/door.ts, which has not
  landed yet (satan:SL-027 PHASE-02). The test guards flakes against itself,
  not against malebolge. Mitigation: satan-a4 acknowledged the DEC-079
  contract and will tell flakes before changing the list (satan 002448b).
- ~/.ssh/malebolge-vm.key is made by hand. Until it exists, the daemon fails
  at connect. SL-027 PHASE-05 plans a launcher check.
- Room literals are still hand-copied from the fleet (satan IMP-044).

Handoff: satan-a4 confirmed receipt (satan 002448b): the literal path, the
schema, `%h = assistant` with HostKeyAlias room-assistant, `--no-local`
clones, and the SL-027 design corrections at its own reconcile.

## Reconciliation Brief

### Per-slice (direct edit)
- design.md sec-4 (F-1): `evalTests = file: …` (name from `baseNameOf file`,
  `failures = import file lib`); call sites `evalTests ./features-test.nix`,
  `evalTests ./host-meta-test.nix`, `evalTests ./features/satan/room-test.nix`.
  Throw text `<file>.nix failed:`.
- design.md sec-6 (F-2): red row goes red against a wrong-valued stub
  room.nix, `git add -N`ed, not an absent file.
- design.md sec-3 (F-3): `inherit (roomDoor.shared) room;`.
- design.md sec-5 (F-3): drop the conditional README row; README unchanged
  (its tree lists features, not files).

### Governance/spec (REV)
- None. DEC-079 holds as accepted.
