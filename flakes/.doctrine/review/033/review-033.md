# Review RV-033 — reconciliation of SL-015

Adversarial-review ledger. Structured findings live in the sister
ledger toml; this prose companion carries the reviewer's framing.

## Brief

<!-- Pre-reading + lines of attack: what this review is probing, the invariants
     it must hold the subject to, and where the bodies are likely buried. Seeded
     at `review new`; the reviewer fills it before raising findings. -->

Mode: conformance self-audit (seat drove PHASE-01..05 via capsule orchestrators;
seat is raiser and responder). Surface: main tree, commits 4e7dba6c..b36c05e9.

Lines of attack:
1. Code vs design.md sec-2..sec-7: relay listener, profiles table, forwarder,
   socket-mode wiring, launch dir, pre-flight, exports.
2. PHASE-05 (added mid-slice at the user's direction, satan:SL-027 RV-035
   F-1/F-6) — wholly outside the locked design: what must the design absorb.
3. Live behaviour of the relay under switch-to-configuration (restartTriggers),
   against the switch's source and the observed journal.
4. Invariants: existing jails byte-identical (PHASE-02/05); socket mode only
   when the profile has no network, guarded at eval; readiness makes no
   upstream connection; no secret added (POL-001); docs match code (VA-2).
5. Conformance algebra and selector registry; governance follow-through
   (SPEC-001, DEC-076).

Evidence: `just gate` exit 0 (before and after the audit's fix-now edits);
`doctrine check gate` green; phase hand-backs; notes.md live sections.


## Synthesis

SL-015 delivered what it set out to: a jail without network reaches the LLM
gateway, and nothing else, through a user-owned unix socket on the existing
relay, with the gateway URL unchanged. Route:

```
features/agents/gateway.nix  relay socket unit: 127.0.0.1:4000 + /run/llm-gateway-client/api.sock (david 0600)
        │                    restartTriggers: a changed socket unit restarts the relay at switch
        ▼
agents/jailed-agents.nix     profiles.<p>.network decides socket mode (gateway != null && !network)
        │
        ▼
agents/gateway-forwarder.nix ro-bind of the client dir; in-jail socat 127.0.0.1:4000 → socket;
                             readiness via /proc/net/tcp + inode of our socat (no upstream connect);
                             eval guard: refused in a jail sharing the host netns
```

Plus `mountLaunchDir` (start in $HOME, no cwd bind) and, from satan:SL-027
RV-035, `workspaceDepsFromEnv` and `persistedHome`.

Evidence held: `just gate` exit 0 at every phase and after this audit's
fixes; existing jail tests unmodified and existing launchers byte-identical
(PHASE-02, PHASE-05); forwarder behaviour tested with real socat in the build
sandbox, including an occupied port and a mutation of the readiness check;
live VA from an offline jail (200 with key, 401 without, :22 refused, router
unreachable) and a TCP control; restartTriggers proven live at the 02:04
switch.

The one behavioural defect the audit found was operational, not code: the
README's recovery command breaks the relay when run while the relay service
is up (F-1, fixed). The switch handles socket-activated units only when both
units are active at switch time; that is now documented with the three
states.

Standing risks:
- Socket mode applied twice fails at launch rather than evaluation (F-6,
  tolerated: fails closed, no consumer).
- The forwarder is not supervised; a socat that dies mid-run surfaces as
  connection refused (design sec-3, accepted at design).
- Conformance stays red for every flakes slice until ISS-005.

Consciously accepted: F-6, F-8 (helper duplication, rule of three), F-9
(PHASE-01 red not captured; no evidential gap).

Worth reading: `doctrine show DEC-076` (transport, readiness: the inode tie
amends it), `doctrine show DEC-077` (egress posture), `doctrine show
SPEC-001` (the client contract this slice extends).

## Reconciliation Brief

### Per-slice (direct edit)
- F-2 — design.md: new section "Env workspace-deps and persisted home
  (PHASE-05)": `workspaceDepsFromEnv ? true` (false never calls getEnv),
  `persistedHome ? null` with the `[A-Za-z0-9][A-Za-z0-9._-]*` eval check and
  why (spliced unescaped into a path and shell), source satan:SL-027 RV-035
  F-1/F-6. sec-3 profiles sketch → `{ network; home; options; }`,
  `profileOptions p home` with persist-home first. sec-7: the impure test
  (`impureChecks.<system>.jailed-agents-env`, run by `just test` with
  `--impure` and JAIL_WORKSPACE_DEPS set; refuses pure eval).
- F-3 — design.md sec-3: readiness requires the LISTEN row's inode to be one
  of our socat's fds (why: a foreign listener on an occupied port); the
  forwarder lives in `agents/gateway-forwarder.nix`. sec-2: relay
  `restartTriggers` on the socket unit, and the switch precondition (service
  and socket active; see README table, F-1).
- F-3/F-4 — design.md sec-6 code-impact table: add
  `agents/gateway-forwarder.nix`, `agents/jailed-agents-env-test.nix`,
  `agents/flake.nix` (`impureChecks`), `justfile` (impure build), and the
  relay `restartTriggers` row; drop "No change to agents/flake.nix".
- F-4 — selector registry (load-bearing): `doctrine slice selector add 15`
  with intent design-target for `agents/gateway-forwarder.nix`,
  `agents/jailed-agents-env-test.nix`, `agents/flake.nix`, `justfile`; sec-6
  is its mirror.

### Governance/spec (REV)
- F-5 — SPEC-001 § Client contract (Reach): two reach paths, `127.0.0.1:4000`
  and `/run/llm-gateway-client/api.sock`; same bearer-key authentication;
  socket mode keeps the URL. § Perimeter: client socket user-owned 0600 in a
  root 0755 dir; `/run/llm-gateway` 0750 unchanged. Cite DEC-075, DEC-077.
  REV modify.
- F-3 — DEC-076: amend readiness wording — "socat PID + its LISTEN row in
  /proc/net/tcp" → the row's inode must be one of that socat's fds. Knowledge
  record edit (`doctrine knowledge edit` / reconcile's choice of verb).

## Reconciliation Outcome

### Direct edits applied (user: "agree to the edits", 2026-10-20)
- design.md sec-2: relay `restartTriggers` and the switch precondition (F-3, F-1).
- design.md sec-3: profiles sketch with `home`; forwarder in `agents/gateway-forwarder.nix`; readiness inode tie (F-2, F-3).
- design.md sec-4: new subsection "Workspace deps and persisted home (PHASE-05)" (F-2).
- design.md sec-6: code-impact rows for gateway-forwarder.nix, jailed-agents-env-test.nix, agents/flake.nix, justfile, restartTriggers; stale "no flake.nix change" removed (F-3, F-4).
- design.md sec-7: items 5(d), 6, 7 and the restart-trigger eval check (F-2).
- Selector registry: 4 design-target selectors added (F-4). Conformance stays red on ISS-005 (flakes/ prefix), not on the registry.

### REVs completed
- REV-012 (`reconcile-sl-015`): done — SPEC-001 § Client contract Reach and § Perimeter amended for the client socket (F-5). Narrative in revision-012.md.

### Knowledge records
- DEC-076: choice amended (readiness inode tie) and body note appended (F-3).

### Tolerated
- F-6, F-8, F-9: rationale in their dispositions.

Reconcile pass complete — handoff to /close.
