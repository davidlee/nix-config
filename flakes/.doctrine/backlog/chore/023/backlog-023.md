# CHR-023: W5 — Migrate /workspace repos to the canonical dev-flake pattern

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

Programme W5. Move each `/workspace` repo with an agents input onto the W4
(IMP-047) pattern: org-incremental-writing, retrograde, satan-attrd, www,
goad, malebolge, panopticon, oubliette, doctrine, screwtape, satan.
Mechanical; delegable per repo. Changes land in each repo, not here.

Per repo: `.envrc` helper, ro/rw deps (W1), form helper where it has a form
(W3), drop stale bits. Known stale: panopticon's devshell still runs
`op run -- jailed-pi` though its jail uses the gateway.

satan last: another agent is reworking its flake (2026-10-27).

After IMP-051: satan's `op-unjailed` check becomes a call to the lib's
scanner as part of its migration, and remaining `useOpEnv` consumers move to
the gateway (panopticon's `op run` is one).
