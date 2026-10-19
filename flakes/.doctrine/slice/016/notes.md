# Notes SL-016: Render malebolge's room door file

Durable per-slice scratchpad — tracked in git. The place to lift anything from a
disposable phase sheet (`.doctrine/state/.../phase-NN.md`) that must survive
`rm -rf` before the slice close-out audit harvests it.

## Design review (2026-10-20)

- Pass: RV-034, human (user accepted sec-1..sec-6 as drafted). User input
  folded in before review: DEC-079 widened to the `[door]` schema; `hostHome`
  naming in `room.nix`.
- Further passes: none needed. The change is data-only; its two risks
  (runner `config.toml` byte-identity, `evalTests` refactor drv-neutrality)
  are checked mechanically in design sec-6. A further pass would probe only
  whether `pkgs.formats.toml` key order could differ, which sec-6's store-path
  comparison settles.

## Context from the user (for the SL-027 handoff)

- In the room, satan reads repos with `git clone --no-local /work/<repo>`
  (CLI flag or git config), never `safe.directory`: `/work/<repo>` is owned by
  another room user, and trusting it would let that repo's config and hooks
  run as satan. Not this slice's to act on; pass to satan:SL-027 with the
  door-file handoff.

## PHASE-01 (2026-10-20)

- Divergence from design sec-4: `evalTests` takes the test file
  (`evalTests ./features-test.nix`), not `name failures`. The name is derived
  from the file, so the stub drv and the throw message name the real file;
  with `name`, `satan-room` would have reported a nonexistent
  `satan-room-test.nix`. The existing checks' drvs and messages are unchanged
  (VA-1, VA-2). Reconcile design sec-4 at audit.
- The three `or`-as-identifier deprecation warnings in `just test` predate
  this slice.

## PHASE-02 (2026-10-20)

- Red: the check failed on all four assertions against a wrong-valued stub
  `room.nix`. An empty stub fails on a missing attribute instead (an eval
  error, not a runTests failure), so the stub carries the keys with wrong
  values.
- VA-1: adding `ssh_config` to `malebolge` fails `testMalebolgeKeys` only.
- VA-2: runner config.toml store path unchanged:
  `gkanmpxgp4fq0v7k7iy874pcam5lpxp5-satan-runner-config.toml`.
- VA-3: built door.toml = `[door]` with home = /home/satan, host_key_alias =
  room-assistant, identity = /home/david/.ssh/malebolge-vm.key, known_hosts,
  room = assistant, user = satan.
- `runner.nix` binds `inherit (roomDoor.shared) room;` (statix's form of
  design sec-3's `room = roomDoor.shared.room;`).
- Outstanding: VH-1 (user runs `just home-switch`, then checks the file);
  VA-4 (SL-027 handoff, with the user's OK).

## Harvest
<!-- single-copy: updated in place each harvest; ids only, never restated content -->
fresh-as-of: <yyyy-mm-dd> · <PHASE-NN | stage> · <head-commit>

### Produced

### Learned

### Open
