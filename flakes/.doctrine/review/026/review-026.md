# Review RV-026 — reconciliation of SL-011

Adversarial-review ledger. Structured findings live in the sister
ledger toml; this prose companion carries the reviewer's framing.

## Brief

<!-- Pre-reading + lines of attack: what this review is probing, the invariants
     it must hold the subject to, and where the bodies are likely buried. Seeded
     at `review new`; the reviewer fills it before raising findings. -->

Conformance audit of SL-011 (LiteLLM credential broker), reviewed in the
primary tree (`$HOME` worktree, main) at 668c69b7. Subject commits: e3542a50,
12251bef, f1e60d07, 0d757dc1, 77103a44, b544a5f5, b17e348a.

Lines of attack:
- **Secrets (POL-001, DEC-048/049):** no provider or client key in argv,
  logs, the store or a jail. That covers every path, not just the happy one:
  failure paths, LiteLLM's own logging, the jail's process tree.
- **Key semantics (DEC-051):** a key reaches only its listed models, within
  budget, priced on the production mapping. Finite guards and CHECKs on every
  write path.
- **Fail-closed service (RV-024 F-5):** no start without a usable credential.
  Rotation must not destroy a working credential.
- **RV-024 routed findings:** each criterion landed and bites (fails with the
  fix removed).
- **Design truth:** design.md matches what shipped, including the live
  adaptations (model list, credential fatality, all-jails empty environment).
- **Conformance:** touched paths vs selectors. `slice conformance` is
  unusable here (ISS-005 `flakes/` prefix), so attribution is per commit, by
  hand.

Evidence: `doctrine check gate` green (just test, treefmt). Live VH-1..7 on
Sleipnir (notes.md). A read-only evidence pass over the code, tests, design,
DECs and LiteLLM 1.102.1 source. The seat read the F-1 code path directly.

## Synthesis

SL-011 delivered what it set out to: a hardened LiteLLM service on Sleipnir
holds the DeepSeek provider key, host+TPM2 encrypted. Jailed eca holds only
its own gateway key, priced per request against a per-key budget. It works
live: eca-2 recorded $0.0051 of real DeepSeek spend. All five RV-024 routed
findings landed as criteria that fail when their fix is removed, and are
verified on RV-024.

The strongest result came from the live checks, not the design: VH-6 found that
bwrap's own environment, readable as /proc/1/environ inside every jail, carried
the launching session's provider keys. Fixing it for all jails (b17e348a) goes
beyond SL-011's design, by user ruling. It closes a leak that would otherwise
have made gateway mode cosmetic. That change, and the live adaptations (served
model, credential fatality, hand-edited eca config), are design truth to
reconcile (F-9, F-10). They are not defects in the code.

Code findings, all fix-now in reconcile:
- **F-1 (major):** a failed `op read` during rotation overwrites the working
  credential, because `systemd-creds encrypt` writes in place.
- **F-2:** the launcher accepts the empty credential that F-1 can produce. The
  two together turn a dismissed 1Password prompt into a gateway that fails
  every request after its next restart.
- **F-3:** LiteLLM's auth-failure path carries raw client keys. It is latent:
  no logger is configured today.
- **F-4:** the model gate ignores Router fallbacks. It is latent: one model
  today, and IMP-029 makes it real.
- **F-5:** the price-map check covers the defaults, not the host's models.
- **F-6:** startup race and start limit.
- **F-7, F-8:** a misleading wrapper message, and parent directory modes.

None is a blocker: nothing leaks today, and the service works.

Standing risks, accepted:
- The credential's host half is on an unencrypted disk (F-12, IDE-006).
- LiteLLM hook drift on upgrade. Pinned by checks.llm-gateway, which runs the
  real proxy offline.
- The offline profile with gateway is not refused: it fails loudly at use.
- `slice conformance` and `verify-vt` give no signal in this repo until
  ISS-005 is fixed, so this audit's conformance is manual.

Out of slice, raised with the user: the emacs flake's `jailed-shell` forwards
seven provider keys and may build its own jail, which this fix does not reach.
The user's preference is to move pi to the gateway and remove keys (IMP-028,
next).

## Reconciliation Brief

### Code (fix-now; reconcile drives a worker, tests red/green)
- F-1: `features/agents/gateway/llm-gateway` `credentials`: encrypt to a temp
  path, then rename over the target only on success; a failure leaves the
  stored credential byte-identical. Add a test.
- F-2: `features/agents/gateway/llm-gateway-serve` `load_credentials`:
  refuse an empty credential, before the LiteLLM import. Add a test.
- F-3: `keystore.py`: issue keys as `sk-<token>`. First confirm that the
  1.102.1 auth path is unchanged (custom_auth only, hash reaches the hooks);
  else escalate. Add a test.
- F-4: `gateway_hooks.py` ModelGate: refuse requests whose fallback or
  routing fields name a model outside the key's list. Add a test.
- F-5: `features/agents/gateway.nix`: a NixOS assertion that every configured
  model is in the packaged price map. Add a test (unpriced override fails eval).
- F-6: `llm-gateway` `credentials`: `reset-failed` before the restart, then a
  bounded wait for api.sock. Remove the README caveat. Add a test.
- F-7: `agents/jailed-agents.nix` gateway outer wrapper: the
  missing-runDirectory message names both causes. Add a test.
- F-8: `llm-gateway`: the key directory chain is created 0700. Add a test.
- README § LLM gateway: update to match F-3 (key prefix) and F-6 (drop the
  caveat).

### Per-slice (direct edit)
- F-9 design.md:
  - sec-1: diagram. Route gate in front of LiteLLM; credstore path
    `/etc/credstore.encrypted/llm-gateway.<p>`; models carried on
    UserAPIKeyAuth.
  - sec-2: a missing credential is fatal at systemd credential setup
    (243/CREDENTIALS), and the first switch reports a failed unit until
    `just gateway-credentials`. Model YAML → `deepseek-flash` only.
  - sec-3: two callbacks (model_gate, ledger), 401/403; `authenticate`
    raises Refused; UserAPIKeyAuth carries `models`.
  - sec-4: first-run example `--models deepseek-flash`; rotation is a new
    alias, since a revoked alias is never reissued.
  - sec-5: `gateway = { keyFile; url; runDirectory; }` and why; offline
    profile not refused.
  - sec-6: VH-1 expectation (systemd 243, journal wording), VH-4 (hand-edit
    eca config.json), F-2 note's model name.
- F-10 design.md sec-5 and sec-7: the all-jails empty-environment launch
  (b17e348a). Cover its cause (bwrap PID 1 environ, VH-6), the
  `bubblewrapPackage` seam, and its effect on the published agents/ flake's
  consumers.
- F-11 selector registry (load-bearing):
  `doctrine slice selector add 11 features-test.nix` as design-target.
  design.md's selector list mirrors it.

### Governance/spec (REV)
- None. DEC-046..051 hold as written. DEC-051's alias semantics were
  reaffirmed by the user (2026-10-17). Rotation by new alias is design-text
  only (F-9 sec-4).

### Backlog (follow-up, already captured)
- F-12 → IDE-006: append the systemd-creds warning as evidence.
- F-14 → ISS-012.
- Related, not findings: IMP-028 (pi onto the gateway; user wants it next),
  IMP-029 (more providers; F-4 must land first).
