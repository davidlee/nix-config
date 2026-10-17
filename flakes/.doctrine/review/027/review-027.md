# Review RV-027 — reconciliation of SL-012

Adversarial-review ledger. Structured findings live in the sister
ledger toml; this prose companion carries the reviewer's framing.

## Brief

<!-- Pre-reading + lines of attack: what this review is probing, the invariants
     it must hold the subject to, and where the bodies are likely buried. Seeded
     at `review new`; the reviewer fills it before raising findings. -->

Conformance audit of SL-012 (PHASE-01..05, commits f7376d7c..78a802b8),
reviewed in the primary tree ($HOME worktree), driven by /capsule-driver.

Lines of attack:
- Path conformance: `doctrine slice conformance 12`, judged by agent (ISS-005).
- Design fidelity: design.md sec-2..6 and DEC-052..057 against the code; the
  phases' "For /reconcile" notes are leads, checked against the source.
- Build safety: `just test`, `doctrine check gate`; only the homes' closures
  may change (+ nix-output-monitor).
- Operability: the first `home-switch` on a home that predates nom (Draupnir).
- Hygiene: unfiled follow-ups, stale memories, research stamp.

## Synthesis

SL-012 delivered what it scoped: the skip list renamed (DEC-052), a probe
list plus a three-state removal check wired into update-* (DEC-053/055), the
lastGood helper and `workarounds/last-good` (DEC-054), `just will-build`, and
home builds through nom. `just test` and `doctrine check gate` are green; the
only closure change is nix-output-monitor in the homes. Conformance reads 0
conformant only because of ISS-005; by agent every code path matches a
declared selector and every selector was delivered.

The one operational defect, F-1, came from the design itself: it made nom
mandatory in the home recipes and installed nom through the home those recipes
build, so a home that predates it could not switch. Fixed in-audit with a
PATH-conditional `nom_pipe` (86df50be), at the user's direction; output-only,
pipefail unchanged.

The rest is wording drift. Phases found that nix serialises any attrset with
`outPath` as a string (so `storePath`), that nixpkgs 24.11 chokes on null
config values, and that the registry sits in `workarounds/`, not `overlays/`.
Design and decisions still describe the plan's first draft; reconcile fixes
the text, not the code.

Standing risks:
- VH-1 is still owed: a real `just home-switch` on Sleipnir (nom tree, failing
  build exits non-zero) and on Draupnir (bash 3.2 sh; first switch now plain).
- The removal check depends on cache.nixos.org reachability; `unknown` warns
  rather than fails, by design (DEC-055).
- `last-good` reads the previous lock, which can equal the current rev (IDE-007).

Accepted tradeoffs: README § Workarounds runs ~135 lines (over the ~60–90
guide) because EX-1 requires each part; lastGood is imported by path until
IMP-032.

## Reconciliation Brief

### Per-slice (direct edit)
- design.md sec-2 (F-3): probe field `storePath` (value: the derivation's
  `.outPath`), not `outPath`; unfree read from `meta.unfree`; add exit 2
  (usage / probes failed to evaluate) to the result table; name
  `workarounds/pin-filter.nix` (shared by check and test) and the explicit
  missing-key check in probes.nix; registry is `workarounds/default.nix` +
  `workarounds/probes.nix`.
- design.md sec-3 (F-3): lastGood passes `filterAttrs (v != null) pkgs.config`
  (why: 24.11 calls `replaceStdenv = null`); add last-good's exit-2 refusals
  (unknown, follows, non-NixOS/nixpkgs input, no lock at HEAD, single lock
  commit); script is `workarounds/last-good`, no just recipe; "last good" is
  the previous lock.
- design.md sec-5 (F-3, F-1): will-build recipe dispatches on `os()`;
  preferLocalBuild has two encodings (plain env, structured `__json`);
  update-* call `just host='{{host}}' will-build` nested; home recipes pipe
  through nom only when it is on PATH (`nom_pipe`), so a pre-nom home switches
  with plain output.
- design.md sec-6 (F-3): tests bullet uses `2>&1 | nom --json` (not `|&`);
  drvs table names three home lines (incl. the `david` alias) and
  `coverage.home@aarch64-linux` also moves.

### Governance/spec (REV)
- DEC-053, DEC-055, DEC-056 (F-2): registry path `overlays/workarounds.nix` →
  `workarounds/default.nix` (probes in `workarounds/probes.nix`) → REV modify.
- DEC-054 (F-2): `bin/workaround last-good` → `workarounds/last-good` → REV modify.
- DEC-036 (F-2): `features/cli-broken.nix` → `features/platform-skips.nix` → REV modify.
