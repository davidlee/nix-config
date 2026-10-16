# VM enablers and agents onto the tree (RFC-001 W6 + W2)

## Context

RFC-001's roadmap ends in W7: `nixosvm`, a headless aarch64-linux guest on the
Mac. W7 needs three things first: W6 (VM enablers), W2 (agents onto the
feature tree) and an answer to QUE-004 (the VM's shape). This slice takes W6
and W2. QUE-004 stays with W7.

Rescoped 2026-10-16 after the research round (`research/research.md`; user:
"agree"). The original framing treated four issues separately. Research found
two root causes:

```
local checkouts are flake inputs ──┬─> ISS-003  recipes need ~/dev/oubliette
  (declared path:, or overridden   ├─> ISS-006  lock records local paths
   into the lock)                  └─> CHR-002, most of IMP-023
agents pieces sit in the wrong place ──> W2 (and the overlay has no consumer)
meta.nix unvalidated ──────────────────> IMP-010 (independent, small)
```

**Dev checkouts.** `agents` and `oubliette` are declared on GitHub but locked
to local sources, because lock-writing recipes pass `--override-input`
(`oubliette` is locked to a dirty tree). `goad`, `panopticon`, `satan-patcher`
and `satan-attrd` are *declared* as `~/dev` paths. All five `~/dev` repos have
GitHub remotes. Whether a checkout exists depends on the machine running
`just`, not on the Nix host config.

**Agents.** The agents overlay (`agentsOverlay`) is applied to every system
and home `pkgs` (`hosts.nix:79,102`) and to `legacyPackages` (`:202`). No
module uses a name it injects; `legacyPackages`, behind `nix.registry.agents`
(NixOS base, `modules/nixos/nix.nix:23`), is its only consumer. eca uses the
agents *input* directly; chatgpt uses `llm-agents`. Both are imported directly
by `hosts/Sleipnir/home.nix` (DEC-031's W2 exception).

## Scope & Objectives

1. **One rule for dev checkouts.** Every flake input is declared by its remote
   URL. One list of dev checkouts (`bin/dev-checkouts`, DEC-037) feeds the
   justfile, and read-only recipes add `--override-input` only for checkouts
   present on this machine. Lock-writing recipes never override. Result: `flake.lock` holds no
   local path (ISS-006) and no recipe fails for a missing checkout (ISS-003).
   Supersedes IDE-002 (override data in `meta.nix`).
2. **Validate `meta.nix`** (IMP-010). A small schema (`kind` enum, `system`,
   optional `home`), checked in `hosts.nix` before any resolution; a bad meta
   fails every evaluation, naming the file. Tests in the existing pure-check
   harness.
3. **Agents overlay only where consumed.** Remove it from system and home
   `pkgs`; keep it on `legacyPackages`. Its own phase; `just drvs` must show
   no change except named ones.
4. **An `agents` area.** `agents.registry` (nixos half: the registry alias,
   out of the base), `agents.eca` and `agents.chatgpt` (homeManager halves,
   Linux), selected through a profile so W7's VM can inherit them.
5. Sleipnir's selection and outputs are unchanged, proved by the drv gate
   (`just drvs`, `drvs-sets`, `probe`, `coverage`), except behaviour changes
   named in the design.

## Non-Goals

- W7 itself: the `nixosvm` host, its machine config, DNS (QUE-004).
- The agents flake's own contents (`agents/`: jail, factories, `dirge`,
  templates).
- A selection-driven (conditional) overlay or any resolver output change;
  research found no consumer that needs one.
- IDE-003..005 (credential broker, brokered git, transcript scanning).
- IMP-023's darwin-specific parts (goad on darwin), IMP-011 (username per
  host, W8).
- W9 tidying (per-host overlays into features, alarm, doctor naming).

## Open questions

- ~~OQ-1~~ Overlay becomes consumer-scoped, not selection-driven (rescope).
- ~~OQ-2~~ eca and chatgpt are `agents.*` features (user, 2026-10-16).
- ~~OQ-3~~ ISS-006 is in scope (user, 2026-10-16).
- ~~OQ-4~~ Override data lives in the justfile, guarded by `path_exists()`
  (rescope).
- ~~OQ-5~~ None of the five `~/dev` repos is private (user, 2026-10-16);
  `github:` URLs need no auth.
- ~~OQ-6~~ Lock-writing commands do record overrides; `emacs` is clean only
  because `nix flake update emacs` re-locked it (CHR-008,
  mem.fact.flakes.fmt-relock).

## Risks

- Dropping the overlay from `pkgs` could change derivations through callPackage
  auto-arguments (`mem.fact.nix.callpackage-autoargs`). Mitigation: its own
  phase, gated.
- Declaring `~/dev` inputs remote needs them pushed first (all are ahead of
  origin); a lock update after a `~/dev` change needs a push. Accepted by
  ISS-006's direction (lock updates on Sleipnir, committed).
- Recipe changes are easy to break on the Mac without a Mac to test on.
  Mitigation: `just --evaluate` with checkouts simulated absent; a VH item for
  a Draupnir run.

## Verification intent

- `just test`: new tests for meta validation.
- `just gate` green; Sleipnir and Draupnir drvs identical except named
  behaviour changes.
- With dev checkouts simulated absent, `drvs` and `probe` evaluate.
- `flake.lock` has no `path` / `file://` node.
- VH: `just drvs` and `just probe` on Draupnir.

## Follow-Ups
