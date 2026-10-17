# REV REV-011 — reconcile SL-013

Revision — a pending revise-intent against authored governance/spec
truth. The structured `[[change]]` payload lives in the sister `revision-NNN.toml`;
this prose companion carries the rationale and the free-text before/after excerpts
for prose-body section edits.

## Rationale

<!-- Why this revision: what authored truth needs to change and why, the scope of
     the staged delta, and (for ADR/POL/STD/prose rows) the before/after excerpts
     the structured payload only labels. Seeded at `revision new`. -->

## Rationale

POL-001's verification list names how the no-secrets rule is checked. Gateway
mode (SL-011, extended by SL-013) is now a check of its own: a jail in gateway
mode holds only its gateway key. SL-011's reconcile deferred this line.

## Before / after (POL-001 § Verification)

Added after "Least-privilege keys for jailed agents (IMP-020).":

> - Jails in gateway mode carry no provider key: the jail tests' no-key probes
>   (`just test`), and live, PID 1's environment empty and `auth.json` holding
>   OAuth logins only (SL-013 VH-2).

## Reconcile narrative

- [RV-030, SL-013 design sec-7]: deferred POL-001 verification line, landed by
  hand. Evidence: SL-013 notes.md § Live checks, VH-2.
