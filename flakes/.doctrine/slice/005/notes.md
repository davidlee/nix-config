# Notes SL-005: Legacy flags to feature tree: hardware, virt, app formats

Durable per-slice scratchpad — tracked in git. The place to lift anything from a
disposable phase sheet (`.doctrine/state/.../phase-NN.md`) that must survive
`rm -rf` before the slice close-out audit harvests it.

## Harvest
<!-- single-copy: updated in place each harvest; ids only, never restated content -->
fresh-as-of: 2026-10-16 · started · acb8a403 (PHASE-03 done)

### Produced
- design locked after RV-011 (8 findings fixed); plan: 4 phases, sheets materialised (commit b2f9367d)
- PHASE-01: `gate-probe.sh`, `hosts/Sleipnir/machine.nix`; hardware flags gone (commit 715e4012)
- PHASE-02: qemu, docker in `features/virt.nix`; rootful docker refused in `security.nix` (commit adc48563)
- PHASE-03: podman an off feature, exclusive with docker; `coverage."Sleipnir+podman"` (commit acb8a403)
- decided: DEC-019 (amended: `machine.nix`), DEC-020, DEC-021, DEC-022 — docker and podman exclusive, podman an off feature
- minted: IMP-018 — podman replaces docker (selection swap after SL-005)
- out-of-band: podman HRIS supabase stack + unused images deleted at the user's request (podman storage 45G → 6.5G)

### Learned
- mem.fact.nix.systempath-collision-first-wins — system-path keeps the first colliding package; sorted-set proofs miss flips

### Open
- design sec-3/sec-7 — distrobox stays in system-path via `modules/nixos/cli.nix`, not only home (correct at reconcile)
- IMP-003 — `dev`, `caddy`, `jackaudio` in `user.nix` name groups absent on Sleipnir (note at reconcile)
- IMP-016 — apps taxonomy, `apps.cad`
- IMP-017 — site-bound config outside DEC-019's machine class
- RFC-001 — W4 class rename to machine config, at reconcile

## Design triage (exploring, 2026-10-15)

Sources: `research/research.md` (D-a…D-f), the user's scope decisions
(see the research header).

**Shaping decisions already taken (user)**
- microcode and ssd → Sleipnir host config, not features (D-a).
- App formats (appimage, flatpak) move now; `apps.cad` deferred → IMP-016 (D-b).
- IMP-003: the docker and libvirtd groups move into their features (D-c).

**Open questions (→ inquiries)**
1. The host-config shape for microcode and ssd: one host-local module or two;
   file name; whether `modules/nixos/{microcode,ssd}.nix` move or are inlined.
2. App formats: one feature or two; feature names; which area (`apps`,
   something narrower, or `virt`/`session`).
3. Selection per feature: `workstation` profile or Sleipnir host property
   (DEC-011 test). qemu needs KVM.
4. Feature body placement: inline in the area file, or own file
   (`features/<area>/<name>.nix`). Delete the `modules/nixos/*.nix` originals?
5. Folding the duplicates (`programs.nix:157-158`, `nix.nix:93-94`): drv effect
   on Sleipnir, and order.
6. Verification: drv gate + `drvs-sets` for ordering diffs, `nix-diff` for
   `extraGroups`; resolver test shape (DEC-014); coverage (none expected).
7. Governance and doc updates: README, the RFC-001 Target-shape wording,
   IMP-003/IMP-006 notes.

**Risks**
- Atomic swap: flag declaration, host setting and gate change together.
- Ordering-only drv diffs (`systemPackages`, `home.packages` unaffected now
  that cad is out, `extraGroups`) need proof.
- Drift in the gate from `system_override` and emacs-overlay; take
  before/after close together.

**Assumptions**
- Darwin reads none of the six flags (research fact 10).
- The ucodenix module does not set `hardware.cpu.amd.updateMicrocode`
  (unverified; moot if microcode stays a host import with unchanged content).

**Constraining governance**: ADR-001 D2/D3/D7, ADR-002 D1–D5, ADR-004 D5,
ADR-005, DEC-011, DEC-014, DEC-015, IMP-003, RFC-001 W3/W4.

## Design review (RV-011, 2026-10-15)

Adversarial pass by the agent, verified against evaluation of Sleipnir and the
pinned nixpkgs. Eight findings, all fixed in the design: see
`doctrine review show RV-011`. User rulings: never rootful docker (assertion
in `security.nix`); `hosts/<h>/machine.nix` (DEC-019 amended); podman should
eventually win `bin/docker`, backlogged as IMP-018 so SL-005 stays
behaviour-preserving.

Sweep beyond scope: `dev`, `caddy`, `jackaudio` in `user.nix` name groups
that do not exist on Sleipnir (for IMP-003 at reconcile).

**A further pass would probe:** whether `lib.hiPrio` survives the rootless
module's second, unprioritised `pkgs.docker` entry (same out path, so it
should); whether any other `systemPackages` path collision exists today (the
link-map gate answers this at execution, so a design pass adds little); and
the `features-test.nix` test shape against DEC-014. None needs another design
pass: each is settled by evidence the gate collects during execution.

Post-review ruling (user, 2026-10-15): fail loud rather than rank `docker`
over podman's shim; podman off entirely. Recorded as DEC-022; `hiPrio` dropped.
Commit order hardware → virt → podman → apps; the exclusivity assertion lands
with podman, since `podman.nix` is unconditional until then.

## Gate snapshots

Outside the repo, one directory per snapshot, each holding `drvs`,
`drvs-sets`, `coverage` and the probe's files
(`.doctrine/slice/005/gate-probe.sh <dir>`):

- `~/.cache/multihost-gate/sl005/baseline/` — before any flake edit (PHASE-01 EN-2), tree at a2b08b34
- `~/.cache/multihost-gate/sl005/phase-01/` — after PHASE-01; PHASE-02's baseline
- `~/.cache/multihost-gate/sl005/phase-02/` — after PHASE-02; PHASE-03's baseline
- `~/.cache/multihost-gate/sl005/phase-03/` — after PHASE-03; PHASE-04's baseline
- `~/.cache/multihost-gate/sl005/phase-03-podman/` — probe of `coverage."Sleipnir+podman"`

## PHASE-01 (2026-10-16)

- Probe: one `nix eval` (justfile `system_override`, no agents pin: the
  registry reaches none of its measures), then `nix build` of `system.path`
  for the link map. About 1 min; the link map is 25,755 lines.
- Gate vs baseline (EX-5, VA-1): `drvs` differs on `nixosConfigurations.Sleipnir`
  only, plus `coverage.Sleipnir+openrgb` (same config). `drvs-sets` identical.
  Probe: packages (463), groups (9), sorted kernelParams, root options, link
  map all identical. `nix-diff` of the toplevel: only `boot.json`, kernelParams
  order (`amdgpu.gpu_recovery=1` from radeon.nix now precedes the two moved params).
- `just gate` green.

## PHASE-02 (2026-10-16)

- Red first: `testSleipnirSelectsMigrated` failed ([false false] twice) before
  the records existed. `sleipnirSelects` (features-test.nix) now serves it and
  testSleipnirSelectsCapsule; it takes literal `<area>.<name>#nixos` tags.
- Gate vs phase-01 (EX-5): `drvs` differs on Sleipnir and its coverage twin
  only; `drvs-sets` identical; probe all identical; `bin/docker ->
  docker-29.8.1`. nix-diff: `system-path` (rest of env identical, sorted paths
  identical: order only) cascading into etc/dbus/units/activate; and
  `users-groups.json`, where `libvirtd.members` lost its duplicate `david`.
  Effective membership identical (libvirtd stays, docker never existed).
- Negative controls (EX-6), temporary coverage entries in hosts.nix, removed
  (hosts.nix == HEAD after):
  - qemu off: `qemu-11.1.1`, `quickemu`, `virt-manager` leave the drv
    closure; `libvirtd` leaves effective groups. The `qemu-11.1.1.tar.xz`
    source stays: it feeds `qemu-utils` / `qemu-host-cpu-only`, pulled by
    other packages.
  - docker off: `docker-29.8.1`, `lazydocker` leave the closure;
    `virtualisation.docker.rootless.enable` false.
- Guards (EX-7): `virtualisation.docker.enable = mkForce true` fails with the
  security.nix message, both with virt.docker selected and with it forced
  off. nixpkgs' own "dockerCompat conflicts with docker" also fires while
  podman is on.
- README: docker's rootless-only note deferred to PHASE-03, with the podman
  exclusivity it sits beside (design sec-8).
- `just gate` green.

## PHASE-03 (2026-10-16)

- Red first: `testPodmanSelectable` failed (`feature.virt.podman` did not
  exist); `testSleipnirLeavesPodmanOff` passes before and after.
  `sleipnirWith extra` now backs `sleipnirSelects`.
- Gate vs phase-02 (EX-4, VA-1): `drvs` differs on Sleipnir and its coverage
  twin only (plus the new `Sleipnir+podman`); home, Draupnir, packages,
  legacyPackages, templates identical. `drvs-sets` 582 → 574.
  - Removed unique packages, path by path: `podman` (podman.nix's entry) and
    `podman` again (the module's wrapped build), `podman-docker-compat`
    (module, `dockerCompat`), `podman-compose`, `podman-desktop`,
    `podman-tui`, `crun`. That is podman.nix's list less distrobox, plus the
    module's two.
  - **distrobox stays in system-path**, not only home: `dev.nix` reaches
    NixOS through `modules/nixos/cli.nix` (`linuxSystem`). One fewer change
    than design sec-3/sec-7 expected; correct those lines at reconcile.
  - Link map: 517 removals, all into podman, podman-man, podman-docker-compat-man,
    podman-compose, podman-desktop, podman-tui, crun; plus
    `lib/systemd/user-generators`, which buildEnv now links as systemd's
    directory instead of merging it with podman's generator (same contents,
    less `podman-user-generator`). `bin/docker -> docker-29.8.1`.
  - Groups: only `podman` gone. kernelParams, root options identical.
  - nix-diff: every changed input is podman's — its units (podman, prune),
    tmpfiles, generators, users-groups, the `podman0` DNS rule in
    nftables-rules, and `network_backend = netavark` / `firewall_driver` in
    containers.conf (set by the podman module).
- Coverage (EX-5): `just coverage` evaluates both targets.
  `Sleipnir+podman` packages include podman; `bin/docker ->
  podman-docker-compat-5.8.8`.
- Guard (EX-6): temporary `coverage."tmp-both"` (podman on, docker from
  workstation) fails with the exclusivity message; removed.
- README: tree listing, intro line, coverage paragraph, and the
  rootless-only / exclusivity paragraph deferred from PHASE-02.
- `just gate` green.
