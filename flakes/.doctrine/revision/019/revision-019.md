# REV REV-019 — SPEC-003: every jail has sound

Revision — a pending revise-intent against authored governance/spec
truth. The structured `[[change]]` payload lives in the sister `revision-NNN.toml`;
this prose companion carries the rationale and the free-text before/after excerpts
for prose-body section edits.

## Rationale

Operator, 2026-11-06: audio belongs in dev-envs, for every jail. Claude's global `Stop` hook plays
a file through `paplay`, so a jail without pulse is silently quiet. SPEC-003's surface table gains
a row: sound in jails, not forms (their drvs are unchanged), and the host's own in a shell.
