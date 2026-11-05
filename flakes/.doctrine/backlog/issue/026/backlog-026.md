# ISS-026: pi-report trusts the jail's quotient shim, which does not reduce

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

`satan:scripts/lib/pi-report-test.sh` passes 9 of 9 on the host and 6 of 9 in a
dev-envs `jailed-shell` (2026-11-05). This is the only red in satan's `just
check` in a jail.

Evidence: in the jail `quotient` resolves to `quotient-jail-shim`, so the
test's `command -v quotient` is true and it runs the reducer path. The output
lacks the tool call, the `## Result` section and the `transcript=` status.

Inference, not yet tested: `pi_report` falls back only when the reducer is not
executable, and the shim is executable, so a real report in a jail may lose its
content without falling back. If so the defect is in `pi_report` or the shim,
and changing the test's guard would hide it.

Found during IMP-063.
