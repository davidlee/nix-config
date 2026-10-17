# Implementation Plan SL-011: LiteLLM credential broker with own key store

Prose companion to `plan.toml`. Narrative only — no queried data lives here
(the storage rule); the phase list, criteria, verification, and links are
authored in the TOML. Use this for the plan's rationale and sequencing.
<!-- Reference forms: `lib:reference/glossary.md` § reference forms. -->

## Overview

Five phases, following the locked design's § Phases and verification (sec-6),
inside out: pure code first, then the LiteLLM boundary, then the system
service, then the jail, then the one client and the human check.

```
PHASE-01 keystore.py + llm-gateway CLI        stdlib, no LiteLLM, no sudo   keystore-test
PHASE-02 gateway_hooks.py + launcher + config  real proxy app, offline        checks.llm-gateway
PHASE-03 NixOS record: units, relay, options   Sleipnir evaluates             just drvs
PHASE-04 jail gateway mode                     agents sub-flake               checks.jailed-agents
PHASE-05 eca + docs + VH 1-7                   on Sleipnir                    human
```

## Sequencing & Rationale

- **Pure before boundary.** The key store and the CLI carry every decision
  (DEC-050, DEC-051) and need nothing but Python's stdlib, so they are
  finished and tested before LiteLLM is touched. PHASE-02 then only binds
  them to LiteLLM's surfaces.
- **The CLI sits in PHASE-01**, not PHASE-03 as design sec-6's table lists
  it, because sec-6's own PHASE-01 proof includes `issue --out`, and
  RV-024 F-6 places its control on "the phase that builds the admin CLI".
  PHASE-03 only installs it. The privileged step (the `sudo -u llm-gateway`
  child) is a seam the test replaces in-process.
- **The launcher sits in PHASE-02** with the adapter: its credential check
  (RV-024 F-5) is tested there; the journal message is VH-1.
- **PHASE-04 does not depend on the service**, only on the constants'
  values, which it takes as arguments. It is ordered after PHASE-03 so
  PHASE-05 lands on a working pair; it could run in parallel.
- **Routed findings** (RV-024, instrument routes, deliberately not repaired
  in prose) are transcribed onto their earliest host phase, citing the
  finding in the criterion: F-3 probe and F-6 control on PHASE-01; F-1 probe,
  F-2 control and F-5 control on PHASE-02. They are verified on RV-024 after
  `slice phases`, against those criteria.

## Risks and mitigations (plan critique)

| risk | mitigation |
|---|---|
| LiteLLM may reach the network in the Nix build sandbox (price map, tiktoken encodings) | PHASE-02 starts with a skeleton check: import the proxy app and serve one `mock_response` call inside the sandbox, with `LITELLM_LOCAL_MODEL_COST_MAP=True` and a writable `HOME`, before writing the rest. If tiktoken fetches, point its cache at a store path or avoid token counting in the test. |
| `mock_response` may skip production pricing (F-2) | Decided at point of use; the fallback (named adapter test on a recorded payload, VH-7 carrying the production claim) is already in PHASE-02/EX-3. |
| Restart storm when the credential is missing (Restart=on-failure, ~25 s start) | The launcher checks credentials before importing LiteLLM, so it fails in milliseconds; systemd's start limit then stops it. VH-1 reads the message. |
| Hardening options break the service on Sleipnir | Only loosened on observed failure, with a comment naming why (PHASE-03/EX-2). |
| sudo re-exec and other hardening never independently reviewed | PHASE-03/VA-1 (residual probes from RV-024, `notes.md`). |
| No Python linter in the repo (treefmt runs alejandra, statix, deadnix) | Run `ruff check` and `ruff format` from nixpkgs on the new Python files each phase; adding ruff to treefmt is out of scope (offer separately). |
| keystore-test runs on the host's `python3` (like `dictate-test`) | Stdlib only; it imports `keystore.py` and loads the CLI from beside itself. |

## Known design drift

The § Shape diagram (sec-1) still shows a route check inside `custom_auth`
and `creds/<provider>.cred`; sec-2 and sec-3 (route gate,
`/etc/credstore.encrypted/`) are authoritative. Correct the diagram at
reconcile.

## Notes

- New files are `git add -N` before evaluating (flakes see tracked files
  only); `nix fmt` without committing the emacs-overlay re-lock.
- The user's uncommitted `justfile` and `flake.lock` edits stay out of
  every commit; stage by path.
