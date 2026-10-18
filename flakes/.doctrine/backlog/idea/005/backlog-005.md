# IDE-005: Scan or purge secret-bearing agent transcripts

POL-001 rule 5. Lower priority than anything committed; whether to purge is
undecided.

A redacted gitleaks scan of `~/.local/share/jail.nix/home` (2026-10-16)
found, outside package caches (npm, cargo, go, bun, plugins — false
positives):

- pi sessions (`.pi/agent/sessions`): 23 `gcp-api-key` (Gemini format), 44
  `generic-api-key` — likely real keys echoed from `env` output, which also
  went to the model provider as tool output.
- codex `.tmp`: 20 `curl-auth-header` — keys in curl command lines.
- `auth.json` / `models.json` (pi, codex): legitimate credential stores.

Hits postdate the 2026-08-11 argv fix, so the env-dump vector is live until
IMP-020 / IDE-003. Options: one-off purge, a `sleipnir-doctor` external
check (`~/.config/sleipnir-doctor/checks.d/`) running a redacted scan, or
both. Rotate any key confirmed real.

2026-10-19: `~/dev/spec-driver/.envrc` holds a plaintext PyPI publish token
(`UV_PUBLISH_PASSWORD`). Gitignored and never committed, but the workspace is
bound into its jails, so any agent there can read it. Rotate it with the rest,
and source it from 1Password instead.
