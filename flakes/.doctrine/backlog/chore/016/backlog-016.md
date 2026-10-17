# CHR-016: Revisit the darwin skips of shell_cmds (killall) and yEd

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

`features/platform-skips.nix` skips `shell_cmds` (killall) and `yEd` on
aarch64-darwin. They are not broken: the user chose to skip them rather than
build them locally while cache.nixos.org lacks them (SL-008 PHASE-07 VH-1).
Both have probes in `workarounds/default.nix` (SL-012, DEC-056).

- **shell_cmds** (probe `killall`): drop the skip when `killall` is on
  cache.nixos.org for aarch64-darwin, i.e. when `just workarounds-check`
  (or the check at the end of `just update-home`) reports `candidate`.
- **yEd** (probe `yed`, `signal = "manual"`): unfree, so never on
  cache.nixos.org and never probed. Check by hand how long `yed` takes to
  build on the Mac; drop the skip if that is acceptable.

Site: `features/platform-skips.nix` (the `aarch64-darwin` list and its
comment), plus the two probes in `workarounds/default.nix`.
