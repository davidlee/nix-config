# Notes SL-018: Read-only workspace deps by default; rw opt-in

Durable per-slice scratchpad — tracked in git. The place to lift anything from a
disposable phase sheet (`.doctrine/state/.../phase-NN.md`) that must survive
`rm -rf` before the slice close-out audit harvests it.

## Design review passes (2026-10-27)

Human review only. A further (adversarial) pass would probe: bwrap's
later-mount-wins behaviour for the launch dir (DEC-082) — asserted from bwrap
semantics, verified only as argv order in tests, since the build sandbox has
no user namespaces; and whether any maker bypasses `makeJailedAgent`'s
workspace args. Judged unnecessary: small surface, behaviour pinned by the
launcher-text tests, and the consumer is the operator.

## PHASE-01 progress (2026-10-27)

- Library: `bindSpecsFor mode static var` builds mode-tagged specs for each
  list; guards (relative, duplicate destination) span the concatenation;
  `bindFlags.${mode}`; launch dir moved after workspace binds.
- Tests: quoting twin per mode; `relativeRwWorkspaceFails`,
  `crossListDuplicateFails`; order asserted by byte offset (`grep -bo`),
  because jail.nix emits the whole bwrap call on one line. Env test covers
  both vars and envOff for both.
- Non-vacuity: three mutants (old bind order; dup guard ro-only; relative
  guard ro-only) each turn `checks.jailed-agents` red.
- `just test`, `just gate` green. `verify-vt` reports UNATTRIBUTABLE for every
  VT: ISS-005 path-prefix misattribution; keywords present, judged met.

## PHASE-02 progress (2026-10-27)

- README: workspace-deps prose (both lists, both env vars, bind diagram,
  cross-list refusal, launch dir last, breaking note); option table row for
  `workspaceDepsRw`; sandbox-defaults line says the cwd binds after the deps.
- Template: header step, both lists with comments, all jails (incl.
  commented) inherit both.
- Emacs flake (`~/.config/emacs` 94a1f9e): notes and .local/state/behaviour
  rw, rest ro. Its untracked `.envrc` listed notes/ in `JAIL_WORKSPACE_DEPS`
  too; removed, since a path in both modes fails evaluation.
- VA-1: built jailed-claude and jailed-pi from the Emacs flake against live
  ~/flakes/agents with the .envrc env: `--ro-bind` flakes, satan-attrd,
  satan-patcher, panopticon, satan (env); `--bind` notes, behaviour; `--bind
  "$PWD"` after every dep (byte offsets).
- VA-2: CHR-023 body has the per-consumer table, the both-lists trap
  (satan's notes) and goad's literal-`~` path (pre-existing refusal).
- `just test`, `just gate` green; verify-vt UNATTRIBUTABLE per ISS-005,
  keywords present.

## Harvest
<!-- single-copy: updated in place each harvest; ids only, never restated content -->
fresh-as-of: 2026-10-27 · audit (RV-040 done) · see git log

### Produced
- design locked, plan authored (commits 113a59bf..044ec3e9); PHASE-01 sheet filled
- minted: DEC-081 — ro default, rw opt-in; DEC-082 — launch dir bound last; RV-039 — design review pass (waived)
- programme backlog W1–W8: IMP-044..050, CHR-023; IMP-051 sequenced; IMP-047 carries the envrc include pattern
- PHASE-01: ro default + rw opt-in in `agents/jailed-agents.nix`, tests, justfile env var
- PHASE-02: README, template, Emacs flake (~/.config/emacs 94a1f9e), CHR-023 hand-off
- RV-040 — audit: F-1 SATAN.md fixed, F-2 CHR-023 extended (7 more consumers), F-3 design sec-5 to reconcile, F-4 aligned (ISS-005), F-5 tolerated

### Learned
- mem.fact.doctrine.plan-toml-editing — plan.toml splice and inline-table traps
- mem.fact.jail-nix.launcher-one-line — bwrap argv is one line; order by byte offset

### Open
- CHR-023 — other consumers' rw lists (handed over; satan, satan-corpus, org-incremental-writing likely need notes rw)
- IMP-044 — resolve `done` at close
- RV-040 brief — design.md sec-5, sec-6 edits (reconcile)
