# SL-007 notes

## Design triage (2026-10-16)

Evidence: `research/research.md` (✓ rows load-bearing).

**Organising principle** (user, 2026-10-16): the structure of options (and
so of files) is the most important interface. A thing is its own feature
when it is cohesive and one would plausibly switch it on or off
independently; the taxonomy must make IA sense — limited depth, roughly
consistent granularity.

**Constraining governance**: ADR-001 D1–D7, ADR-002 D1/D5/D7, ADR-004 D1–D3,
ADR-005, DEC-004, DEC-005, DEC-007, DEC-011, DEC-015, DEC-016, DEC-019,
DEC-021, DEC-023, DEC-024, DEC-025; memories `mem.pattern.flakes.drv-gate`,
`mem.fact.nix.merge-order`, `mem.fact.nix.systempath-collision-first-wins`,
`mem.fact.nix.sudo-rule-order`, `mem.fact.nix.verify-closure-not-option`,
`mem.fact.flakes.git-add-n`.

**Shaping decisions to make**: base shape/name/content; desktop foundation
granularity; hardware placement (incl. radeon); audio foundation; services
and apps placement (postgresql, avahi, 1Password, dev libs); host / machine /
site split (network, nix tuning, stateVersion, kernel patch, swapfile,
rtcwake); base verification on aarch64; defects with the IMP-004 prune;
phasing.

**Risks**: merged-list reorders and `systemPackages` collision flips
(13 duplicates listed in research); a fat base; aarch64 eval breakers in
base candidates (cpuid, x86info, Rust kernel patch).

**Assumptions**: SL-006 gate + `just probe` carry over; W7 is headless
aarch64 under UTM.

**Open questions**: as above; QUE-004 stays W7's.

## Review passes (2026-10-16)

RV-015: agent self-pass, 4 findings (F-1..F-4), all fixed and verified.
A further hostile pass would probe: negative-control signatures that another
module also sets (rtkit, bluetooth, portals under cosmic/kde), so a control
passes vacuously; aarch64 breakers beyond cpuid/x86info in the base closure;
the record-imports-modules form for desktop.core against ADR-002 D1/D7 and
the README "own file" rule; and what config.nix still imports flat during
P1–P4 (interim states the phase table does not draw).

RV-015 second pass (run rev 36→38): agent pass on those probes (F-12..F-14)
plus a user-relayed external agent pass (F-6..F-11, F-15). F-6 (major):
user chose to revise ADR-002 D3 → REV-006 (proposed, applied in P3). F-15
contested (drvs-sets counts duplicates). Concluded; all verified.

## Harvest
<!-- single-copy: updated in place each harvest; ids only, never restated content -->
fresh-as-of: 2026-10-16 · PHASE-01..06 committed (0a7458d5..9fe49432); audit RV-016 done · awaiting /reconcile

### Produced
- DEC-026, DEC-027, DEC-028, DEC-029; design.md (sec-1..9); RV-015
- REV-006 approved (user, e45ee531) and applied: ADR-002 D3 + README own-file rule (ae61a072)
- plan.toml / plan.md (PHASE-01..06); ASM-001
- code: base `modules/nixos/default.nix`; `hosts/Sleipnir/{machine,dns,oom,config}.nix`;
  features `desktop.{core,greeter}`, `compositor.*`, `shell.noctalia`, `audio.pipewire`,
  `hardware.{bluetooth,qmk,tablet,logitech}`, `services.postgresql`; `coverage."base@aarch64-linux"`
- memory `mem.fact.nix.kernel-rust-by-default` (9fe49432)
- RV-016 (audit, 6 findings: F-1 fixed in audit; F-2, F-5, F-6 → reconciliation brief)
- observations (friction) from the capsule run: gate-probe blind spots, /etc registry.json
  false positive, planner turn cap, stale controls/run.sh restore()

### Learned
- Probe blind spots: changes NixOS deduplicates (allowedTCPPorts) and nonexistent groups
  leave no build trace; evidence is option-level (RV-016 F-2).
- `/etc` comparisons must exclude `nix/registry.json` (flake source path changes every edit).
- Moving `nix-ld.libraries` entries always changes the `ld-library-path` drv (order-only).
- With cosmic selected, rtkit/bluetooth negative controls are masked (design sec-5).
- Negative-control host overrides: wrap the host attrset in `imports = [ … ]`.
- `rtcwake` sudo rule is live: `~/.local/bin/snooze` (RV-016 F-1).
- slice conformance / verify-vt are blind here until ISS-005 (`flakes/` prefix).

### Open
- Next: /reconcile per RV-016 Reconciliation Brief (design §7, selectors, RFC-001, DEC-016, DEC-024), then /close (IMP-004 → done)
- Follow-ons: IMP-022 (oom per host), IMP-002 (dns.nix private hostname), CHR-014 (i2c),
  ISS-005, IMP-017, IMP-003, ISS-008, QUE-001, QUE-004; candidate cleanup: split
  `features/desktop/core/gui.nix` by concern
- Untracked doctrine files on disk outside this slice (backlog slug symlinks, POL-001 symlink, observations)

## Gate snapshots

HEAD f9c57b3a (uncommitted worktree delta for PHASE-01).

- baseline (unchanged tree): `~/.cache/multihost-gate/sl007/baseline/` — drvs 13 lines, drvs-sets 5, coverage 6, system/ + home/ probe; re-probe into `baseline-recheck` identical (deterministic); `just gate` green.
- PHASE-01: `~/.cache/multihost-gate/sl007/phase-01/` (PHASE-02's baseline). Same line counts.

### PHASE-01 verdict: order-only (P1 row)
- drvs: only `nixosConfigurations.Sleipnir` differs, plus the six `coverage.Sleipnir+*` lines (same base). Home, Draupnir, packages, legacyPackages, templates identical.
- drvs-sets: Sleipnir count 570 unchanged; hash differs only through the reordered `ld-library-path.drv`.
- probe: `diff -r system home` empty except `system/packages` (one drv, ld-library-path, moved). `system-path-links` identical (no collision winner flipped).
- nix-diff of toplevel (`phase-01/nix-diff-toplevel.txt`) traces every difference to list order: nix-ld `ld-library-path` (120 entries, same multiset, different order; `nix-diff-ld-library-path.txt`), sudoers (`nft list table inet capsule-forward` rule now after the wheel rtcwake rule; commands do not overlap), boot.json kernelParams order (`boot.shell_on_fail` / `amdgpu.gpu_recovery=1` swapped).
- Cosmetic: alejandra collapsed config.nix's arg list to `{inputs, ...}:` (`pkgs` unused after nix.package moved); drvs re-run stable after formatting.
- `just gate` green (tests + treefmt).
- Friction: `nix-diff` env diffs dump huge single lines; use `cut -c1-200` and decode `__json` via `nix derivation show | jq`.

### PHASE-02 verdict: order-only (P2 row), /etc identical modulo order

HEAD 0a7458d5 + uncommitted PHASE-02 delta. Snapshot `~/.cache/multihost-gate/sl007/phase-02/` (PHASE-03's baseline): drvs 13, drvs-sets 5, coverage 6, `system/` + `home/` probe, `etc` (GC root). T0 added the baseline's built `/etc` as `phase-01/etc` (359 symlinks).

- drvs: only `nixosConfigurations.Sleipnir` and the six `coverage.Sleipnir+*` lines differ. Home, Draupnir, packages, legacyPackages, templates identical.
- drvs-sets: identical (Sleipnir 570, same hash). probe: `diff -r system home` empty, including `system/packages`, `kernelParams` and `system-path-links`.
- nix-diff of toplevel (`phase-02/nix-diff-toplevel.txt`): three leaves, all order-only, everything else fallout (dbus-1, system/user units, restart triggers, activate):
  - `system-path`: only `chosenOutputs` differs; sorted multiset equal (570 = 570).
  - `sudoers-in`: the wheel rtcwake rule moved after `nft list table inet capsule-forward` (back to its pre-PHASE-01 place); sorted lines equal.
  - `boot.json`: `amdgpu.gpu_recovery=1` moved one place in kernelParams; sorted equal.
  - Not moved: `modules-load.d/nixos.conf`, `modprobe.d/nixos.conf`, users-groups (extraGroups), swap.
- /etc (VA-3), link-map diff `phase-02/etc-linkmap.diff`: gai.conf, stubby.yml, the `wired` NM ini, resolved.conf, nix.conf (`max-jobs = 4`, `cores = 4`), modules-load.d, modprobe.d, NetworkManager.conf all point at the same store paths. Changed links: `sudoers` (order only, above); `dbus-1`, `systemd/system`, `systemd/user`, `terminfo` (identical after normalising the system-path/unit store hashes); `nix/registry.json` (only the `agents` registry `path`, the flake's own source path, which changes with any source edit — the reason `nixos_pick` pins it in `just drvs`; the T0/T6 `/etc` build does not pin it).
- VA-1 sudoers rendering: `root ALL`, `%wheel ALL` first; then nft capsule-forward, rtcwake, capsule-proxy restarts; commands disjoint.
- VA-2 POL-001: `phase-02/pol001-added-tokens.txt` — added-only tokens are comment words, attr paths, file paths and ids (POL-001, IMP-002, IMP-022, DEC-029, SL-007, PHASE-06). `1qncxpyinu9`, `76.76.`, `2606:1a40`, `192.168`, `enp8s0`, `controld` each removed = added. Values only moved.
- README edits came after the snapshot; they do not change any evaluated drv (`just drvs` pins the registry), so no re-run.
- `just gate` green (tests + treefmt); statix and deadnix clean on every touched file.

### PHASE-06 verdict: exactly the § Behaviour changes table

HEAD 22f18329 + PHASE-06 delta. Snapshot `~/.cache/multihost-gate/sl007/phase-06/` (drvs, drvs-sets, coverage, system/, home/, etc, etc-linkmap-p6.txt, kconfig-*, controls/, nix-diff-toplevel.txt). Worker: opus.

**EN-2 / VA-3 kernel .config, compared before any edit: byte-identical.**

| | with Rust kernelPatch | plain `linuxPackages_latest` |
|---|---|---|
| drv | `bgk4w9h9ghcdm0dayhdhgfbzqjxgmvls-linux-config-7.2.9.drv` | `zrwj0xq9xnas4lm4f0lrg37smrpgqhwc-linux-config-7.2.9.drv` |
| out | `qgq1g99558k1mx0x4qwq2xjg5d1h6mj8-linux-config-7.2.9` | `xjk678mq2by79ij74b6smawwpcypykal-linux-config-7.2.9` |
| sha256 | `f60534634b18c9e52bbef1c1e71ff0dd703e788e74584b731d3fbf8164c340ff` | same |

`diff` rc=0 (orchestrator re-checked with `cmp`). Plain config has `CONFIG_RUST=y`. Cause: nixpkgs `common-config.nix:48` `rustByDefault` (kernel >= 6.12 on x86_64); the patch only turns intermediate `RUST? y` into `RUST y`, making an uncached kernel drv. After removal the Sleipnir kernel drv equals `linuxPackages_latest` (`cic6a72y…-linux-7.2.9.drv`), output on cache.nixos.org.

**EX-2 / VA-1 gate vs PHASE-05.**
- drvs: only `nixosConfigurations.Sleipnir`; coverage: six `Sleipnir+*` and `base@aarch64-linux` (B5/B6 live in `modules/nixos`).
- drvs-sets: Sleipnir 570 -> 565 (-5 IMP-004 prune, -1 duplicate sway-easyfocus, +1 helix). Home, Draupnir identical.
- system/packages: wob, i3status, wf-config, gnomeExtensions.appindicator, marble-shell-theme gone; helix added; `ld-library-path` drv lost helix. system-path-links: only those removals plus helix's `bin/hx`, desktop file, completion, icon; no surviving link retargeted; mimeinfo/icon-theme caches regenerated.
- /etc (`nix/registry.json` ignored): `pam.d/greedt` gone; dbus-1, systemd units, terminfo identical after store-hash normalisation; `sysctl.d/55-nixos-aslr-entropy.conf` content identical, drv moved via linux-config input (kernel-bound, B7).
- dev group: no probe or drv change — the probe lists existing groups and `dev` never existed; evaluated `extraGroups` no longer contains it.
- firewall: rendered `nftables.service` byte-identical (NixOS dedups); option `allowedTCPPorts` = `[22,80,443,27015,27036,27037,27040]`, no duplicates.
- Everything else in the probe (ports, kernelParams, udev, fontconfig, home/*) identical.

**VA-2** webserver `mkForce false`: allowedTCPPorts `[22,27015,27036,27037,27040]`, caddy absent. Controls copied to phase-06 with post-edit host files (phase-05 `restore()` would re-add the kernelPatch); restore verified via `git diff -- hosts/Sleipnir`.

**EX-3 / VA-4** `modules/nixos` = default.nix + its 16 imports + parked hyprland.nix, kmscon.nix. Close grep empty after rewording `hosts/Sleipnir/machine.nix` comment (named the old radeon.nix path; not a table row, needed for EX-3). Removal greps empty; sway-easyfocus once; no `greedt`/`kernelPatches`. `just gate` rc=0; statix, deadnix clean.

Learned: probes cannot show B4/B5 (dedup, undefined groups) — evidence is option-level eval. Sourcing `controls/run.sh` overwrites `$S`; use its `$C`.
