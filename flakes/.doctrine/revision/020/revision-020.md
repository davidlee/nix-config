# REV REV-020 — SPEC-003: a jail advertises zmx state on its host session

Revision — a pending revise-intent against authored governance/spec
truth. The structured `[[change]]` payload lives in the sister `revision-NNN.toml`;
this prose companion carries the rationale and the free-text before/after excerpts
for prose-body section edits.

## Rationale

Operator, 2026-11-07: a jailed harness advertises `state` on the host zmx session it was launched
in, without holding a zmx socket (IMP-070, sketch agreed that day). SPEC-003's surface table gains
a row: jails only, and the host's own zmx in a shell.
