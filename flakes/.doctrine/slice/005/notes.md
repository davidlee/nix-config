# Notes SL-005: Legacy flags to feature tree: hardware, virt, app formats

Durable per-slice scratchpad — tracked in git. The place to lift anything from a
disposable phase sheet (`.doctrine/state/.../phase-NN.md`) that must survive
`rm -rf` before the slice close-out audit harvests it.

## Harvest
<!-- single-copy: updated in place each harvest; ids only, never restated content -->
fresh-as-of: 2026-10-16 · started · 715e4012 (PHASE-01 done)

### Produced
- design locked after RV-011 (8 findings fixed); plan: 4 phases, sheets materialised (commit b2f9367d)
- PHASE-01: `gate-probe.sh`, `hosts/Sleipnir/machine.nix`; hardware flags gone (commit 715e4012)
- decided: DEC-019 (amended: `machine.nix`), DEC-020, DEC-021, DEC-022 — docker and podman exclusive, podman an off feature
- minted: IMP-018 — podman replaces docker (selection swap after SL-005)
- out-of-band: podman HRIS supabase stack + unused images deleted at the user's request (podman storage 45G → 6.5G)

### Learned
- mem.fact.nix.systempath-collision-first-wins — system-path keeps the first colliding package; sorted-set proofs miss flips

### Open
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
