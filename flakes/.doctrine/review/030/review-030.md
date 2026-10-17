# Review RV-030 — reconciliation of SL-013

Adversarial-review ledger. Structured findings live in the sister
ledger toml; this prose companion carries the reviewer's framing.

## Brief

<!-- Pre-reading + lines of attack: what this review is probing, the invariants
     it must hold the subject to, and where the bodies are likely buried. Seeded
     at `review new`; the reviewer fills it before raising findings. -->

Mode: conformance (self-audit; one agent drives raiser and responder).
Surface reviewed: main worktree (`~/flakes` at e10a24d2), plus emacs 069e9b6,
doctrine 7100b81f3 and home-repo commits 93693ea1, 6f9ad795. Capsule-driven, not
dispatched: no candidate branch.

Lines of attack:
- Code vs design.md sec-2..sec-6: names, bind order, error text, consumer lists,
  rollout order.
- Design and README prose made stale by what was built.
- sec-6 VT cases: present, and each actually testing its property (twins).
- POL-001 (public repo: no secrets, classified identifiers): nothing committed
  under the jail homes or the slice carries a key or Private-tier identifier.
- Leftover `op run` / OPENROUTER_API_KEY / apiKeys / dirge / opencode in the
  consumers the plan migrated.
- Evidence durability: every EX/VA/VH result recorded outside disposable sheets.

Invariants: `just drvs` neutral for every host (PHASE-01/02); gateway mode puts
no provider key in a jail; pi's providers come only from the generated
models.json bind.

Gate at audit: `just gate` exit 0, `doctrine check gate` exit 0 (warnings: dirty
tree, lock-override notices, upstream `or`-identifier deprecation only).
Conformance: registry complete after recording PHASE-04/06 rows; cells
misattributed by the `flakes/` prefix (ISS-005).


## Synthesis

SL-013 delivered what the design locked. Gateway data lives in
`agents/gateway.nix`; the NixOS gateway and every client read it. pi jails get
a generated `models.json` bound read-only over the persisted one, after the home
bind. The template, the emacs devshell and doctrine all launch their jails
through `gatewayClient "pi"`, with no `op run`. Host build hashes did not move
(PHASE-01/02 neutral, only `templates.*` after PHASE-03). The live checks
confirmed the invariants on the running host: the jail's PID 1 has an empty
environment, `auth.json` holds only OAuth logins, and pi's only provider is
`llm-gateway`.

No blocker or major finding. Twelve findings: the design prose lags the code in
four places (F-2, F-4, F-8, F-9), the evidence and docs had gaps now closed
(F-3, F-6, F-10, F-11, F-12), and two are owned future work: the missing-key
hint (F-7, ISS-014) and the test oracles (F-5, IMP-036).

Standing risks:
- The missing-key hint suggests the wrong alias for shared-key jails and a
  revoked one after rotation (ISS-014). A user following it gets a key nothing
  reads, or a refusal.
- The models.json tests confirm the data source, not the content (IMP-036);
  a wrong pi block in `agents/gateway.nix` would pass them. The live checks
  are the only content evidence.
- Jails not yet migrated (other `~/dev/*` flakes, IMP-034; satan, IMP-030)
  still carry seven provider keys in their environment (VH-8).

Accepted tradeoffs:
- The template's opt-out comment names `op run` (F-2): it tells the reader the
  cost of `gateway = null`.
- Conformance stays red by tool limit (F-1, ISS-005); judged by hand it is
  clean.

Incidents during PHASE-06, both resolved: the `pi` gateway key was pasted into a
session and rotated to `pi-2`; running `llm-gateway issue` under sudo left the
key file root-owned (ISS-015).

## Reconciliation Brief

### Per-slice (direct edit)
- design.md sec-3 (F-8): the snippet's inline `(import ./gateway.nix)` becomes
  one top-level `gatewayData = import ./gateway.nix`, used by `piGatewayModels`
  and `gatewayClient = gatewayData.client`; note why it isn't named `gateway`.
- design.md sec-4 (F-2): after the template's opt-out comment, say it names
  `op run` deliberately and is the single accepted match for PHASE-03 VA-1's rg.
- design.md sec-4 (F-9): the doctrine entry also removes the `jdi` devshell
  command (it ran jailed-dirge) and replaces the API-key-forwarding comment.
- design.md sec-6 (F-4): the missing-pi-entry case proves evaluation fails; the
  message naming the model was checked by hand (`nix eval`), not by the test;
  a message-holding test is IMP-036.

### Governance/spec (REV)
- ADR-004 D4 (design sec-7, planned): apply REV-009 — D4 admits imported
  constants for fixed shared facts (`agents/gateway.nix` is one).
- POL-001 verification (design sec-7, planned; deferred from SL-011): add a
  gateway line — a jail in gateway mode holds no provider key (PID 1 environ
  empty, `auth.json` OAuth-only; VH-2 is the evidence). REV modify.

### Records (direct edit)
- mem.fact.bwrap.pid1-environ-leak (design sec-7, planned): its last line says
  jails built outside agents (the emacs `jailed-shell`) miss the env fix; the
  research found that wrong — every emacs jail now builds through jailLib.
- notes.md § Harvest: refresh to done-state ids (ISS-014, ISS-015, IMP-036,
  RV-030).

### Outside the doctrine repo (user go-ahead needed)
- ~/dev/doctrine/flake.nix:403-411 (F-9): drop "identical drvs the jails
  bundle" from the unjailed-dirge comment; no jail bundles dirge.

## Reconciliation Outcome

### Direct edits applied
- design.md sec-2 table and sec-3 snippet: one top-level `gatewayData = import ./gateway.nix`; `gatewayClient = gatewayData.client` (F-8).
- design.md sec-4 template: the opt-out comment names `op run` deliberately; it is the one match PHASE-03 VA-1 accepts (F-2).
- design.md sec-4 doctrine: `jdi` removed with jailed-dirge; the API-key-forwarding comment replaced (F-9).
- design.md sec-6: the missing-pi-entry case proves failure only; the message was checked by hand; IMP-036 (F-4).
- ~/dev/doctrine/flake.nix unjailed-agents comment, with the user's go-ahead: doctrine f3ee07d38 (F-9).
- mem.fact.bwrap.pid1-environ-leak: last line corrected; every emacs jail builds through jailLib (design sec-7).
- IMP-036: its message-check item marked obsolete once SL-014's DEC-066 makes the pi block optional.

### REVs completed
- REV-009 (ADR-004 D4 admits imported constants): done, landed by hand in ADR-004 § Decision, Settings, item 4.
- REV-011 (`reconcile-sl-013`): done, POL-001 § Verification gains the gateway-mode line (VH-2 evidence).

### Withdrawn / tolerated
- F-1: tolerated, conformance misattribution by the `flakes/` prefix (ISS-005).
- F-5, F-7: follow-up, IMP-036 and ISS-014.

Note: SL-014 (DEC-066) will make a served model's pi block optional, reversing
the throw this slice built; the README sentence and the test belong to it.

Reconcile pass complete; handoff to /close.
