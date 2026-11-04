# Review RV-047 — reconciliation of SL-023

Adversarial-review ledger. Structured findings live in the sister
ledger toml; this prose companion carries the reviewer's framing.

## Brief

Conformance audit of SL-023 against design.md, plan.toml, SPEC-003 and DEC-107..121.
Surface reviewed: the primary tree (flakes 9520d258; doctrine 7eddc8ea1; fleet a9b384f). Not a dispatched slice.

Lines of attack:

- Does each host fact have one owner, and does every reader get it (DEC-107, DEC-108, DEC-109)?
- Does one Doctrine path hold in every jail that can see a baked path, not only those PHASE-07 ran (S5)?
- Does moving env to host-wide reach confinement the slice did not test (DEC-114, DEC-121)?
- Does the consumer evaluate standalone, and do its refusals cover what the layers own (DEC-114, DEC-120)?
- Is each scope promise delivered, including S3's way back on the Mac?
- Do conformance, tests and the gate agree once ISS-005's path prefix is normalised?

## Synthesis

**Closure story.** SL-023 delivered what it scoped. Doctrine is a producer; the
consumer builds five jails, two forms and a shell; host facts have one owner; one
Doctrine path holds on the host and in current jails; the symlink is gone.
Tests, gate and format are green after the repairs below. Conformance needed hand
normalisation (ISS-005): nothing was undelivered, and five edited paths lacked a
design-target selector.

The audit's one blocker was outside what PHASE-07 ran. DEC-121 reasoned about the
library's jails. Doctrine's dispatch jail is a different shape: `--ro-bind / /`
with an inherited env. Moving sccache to a host unix socket made cargo fail in
that jail unless a host server was running, and left compiles reachable when one
was. The user chose option A. The dispatch prefix now sets its own socket, which
changes env only, so the slice's Non-Goal on confinement holds. F-2 and F-5 were
repaired with it.

**Evidence and its limits.** Measured: `just test` and Doctrine's `just gate` rc 0
after the repairs; the confinement test runs the shipped prefix; forms unchanged,
so no new `quotient allow`. Hand probes used the prefix's shape, not a real
dispatch run. Inferred, not run: F-1's claim that a compile on the host server
would run outside the jail, and F-3's MCP failure in older-pin jails.

**Standing risks.**

- F-3 (IMP-060): jailed codex, and pi in re-baked repos, may lose Doctrine's MCP
  server in repos on older `agents` pins until they migrate.
- F-4 (CHR-029): `dev-envs` does not evaluate at its own lock until the operator
  pushes and the pin moves. Every entry point overrides it, so nothing green shows
  this.
- RSK-001: networked jails still share host loopback.
- A new whole-root jail elsewhere inherits the same exposure: the host address is
  safe only where the jail sets its own.

**Tradeoffs accepted.** F-10's two plan-criterion departures are tolerated:
one clause cannot be performed, and the other substitution differs only in agent
and PATH. A form's caches stay per-run (IMP-059).

**Route through the change.** `agents/dev-env.nix` holds the host list;
`dev-envs/flake.nix` applies it with the project's `devEnv`;
`agents/jailed-agents.nix` confines; `~/dev/doctrine/flake.nix` produces. The
behaviour most worth reading is sccache's address: `hostOnlyEnv` for host shells,
`envOptions` for library jails, `spawn-confined.sh` for dispatch. Tests:
`checks.dev-env`, `checks.factories`, `jailed-agents-test`,
`doctrine:tests/e2e_worker_confinement.rs`. `doctrine show DEC-121` is the
decision to read; `doctrine show SPEC-003` is the contract; `doctrine show RSK-001`
is the remaining class of risk.

## Reconciliation Brief

### Per-slice (direct edit)

`design.md`:

- F-7, § The consumer, § Verification: `project` is `flake = false`, evaluated by
  flake-compat against the project's own lock; the diff may require identical
  dev-tools paths (PHASE-05 F-1). § Verification R5 row: covers agents-library
  drift too (PHASE-05 F-3).
- F-7, § The consumer, § The shell, § Handover: DEC-120's agents override and
  watches; no push and re-lock before subtraction. § Code impact: `bin/dev-envs-forms`
  and its test changed.
- F-7, § Host facts, § The jail library: `for` returns
  `{env; hostOnlyEnv; packages}`; the library sets `SCCACHE_SERVER_UDS` (DEC-121).
  `SCCACHE_DIR` is not a host fact; § `.envrc` wording (PHASE-06 D-1).
- F-7, § The Nix-built Doctrine: `bind-pkg`, not `ro-bind` (PHASE-02 D-1).
- F-7, § The project's env: `errors` and `checkDevEnv` live in
  `dev-envs/dev-env.nix`; `hostNames` covers `hostOnlyEnv` (F-2).
- F-1, § Failure modes, Code impact: add the dispatch row;
  `doctrine:scripts/spawn-confined.sh` and `pi-respawn-nofork.sh` are touched.
- F-3, § Arrangement "Boundary": other repos' jails include ones with no own bind;
  IMP-060 owns them.

`slice-023.md`:

- F-8: "DEC-106's export contract ... is superseded" follows the outcome below.

Selectors (load-bearing; § Code impact is the mirror):

- F-9: `doctrine slice selector add` as design-target: `hosts.nix`, `justfile`,
  `dev-envs/dev-env.nix`, `dev-envs/dev-env-test.nix`,
  `dev-envs/stub-project/flake.lock`.

### Governance/spec (REV)

- F-1, REQ-029: "which no jail binds" is false. Restate: every jail sets its own
  socket, including dispatch's. → REV modify, then status from evidence.
- F-11, SPEC-003 § `devEnv` schema: refusals cover `hostOnlyEnv` names; drop "(see
  § Concerns)" there. § Concerns: remove the `SCCACHE_SERVER_UDS` bullet (F-2 closed
  it); § Open questions: its first question narrows to other library-set names.
  § Mechanism: `checks.dev-env` runs against the real `hostDevEnv`. Add the dispatch
  jail and its sccache socket to § Concerns or § What each surface gets. → REV modify
- F-11, REQ-024..030: statuses from PHASE-07 and `just test` evidence. → REV status
- F-11: link SL-023 to SPEC-003 in the graph (`doctrine link`).
- F-8, DEC-101, DEC-103, DEC-106: settle against DEC-113 and DEC-114, by supersede
  or by amending text. DEC-102: link target is `bin/quotient-<c>`.
- DEC-121, DEC-114: note `hostOnlyEnv` and the dispatch socket in their text.

## Reconciliation Outcome

### Direct edits applied

- design.md § Arrangement "Boundary": other repos' jails with no own bind; IMP-060 owns them (F-3).
- design.md § Host facts, § The jail library: `for` returns `hostOnlyEnv`; the library sets
  `SCCACHE_SERVER_UDS`; `SCCACHE_DIR` is not a host fact; `bind-pkg` (F-7).
- design.md § The consumer, § The project's env, § The shell, § Forms, § `.envrc`: `flake = false` and
  flake-compat; DEC-120; `checkDevEnv` beside `errors` and `hostNames`; refusal row covers
  `hostOnlyEnv` (F-2, F-7).
- design.md § Failure modes, § Code impact, § Verification, § Handover: dispatch row; touched paths;
  identical `dev-tools`; R5 row; no push and re-lock before the subtraction (F-1, F-7, F-9).
- Selectors: `hosts.nix`, `justfile`, `dev-envs/dev-env.nix`, `dev-envs/dev-env-test.nix`,
  `dev-envs/stub-project/flake.lock` are design-target (F-9).
- slice-023.md: no edit. Its "DEC-106's export contract ... is superseded" is now true (F-8).
- SL-023 references (implements) SPEC-003 (F-11). `doctrine link` refuses the `specs` label that
  the slice toml's comment suggests.

### REVs completed

- REV-015 (`reconcile-sl-023`): done. SPEC-003 prose, REQ-026 and REQ-029 text landed by hand;
  REQ-024..030 → active, REC-001..007 (F-1, F-2, F-11). Rationale in revision-015.md. REQ-026's
  edit was not in the brief; it follows from F-2.

### Decisions (knowledge verbs, user "agreed")

- DEC-113 supersedes DEC-101 and DEC-106 and carries what survived (F-8).
- DEC-103 amended and accepted; DEC-102's link target corrected (F-8).
- DEC-121's choice and consequences, and DEC-114's body, name `hostOnlyEnv` and the dispatch socket.
- DEC-100, DEC-102, DEC-104, DEC-105 accepted: beyond the brief, at the user's agreement.

### Coverage

VA cells recorded on SL-023 for REQ-024..030. They carry no `touched_paths`, so each reads `stale`
and each verdict `Indeterminate`. /close discharges these with accept RECs
(`mem.pattern.doctrine.close-drift-discharge-rec`).

### Open at handoff

- REQ-029 went `active` on the condition that the operator commits F-1's repair in ~/dev/doctrine
  before /close. No real dispatch worker has run it.
- design.md now differs from design run revision 42 (`design show` says it is behind the run).
  Running `doctrine design materialise SL-023` could overwrite these edits.

### Withdrawn / tolerated

- F-10: tolerated, rationale in its disposition. F-3, F-4, F-6: follow-ups IMP-060, CHR-029, IMP-061.

Reconcile pass complete: handoff to /close.
