# IMP-021: Pre-commit secret scan (gitleaks) for the home repo

POL-001 verification. Nothing checks a commit before it lands: the hooks
directory (`core.hooksPath = ~/.config/git/hooks`) holds only a
`post-commit` hook (satan). Add a `pre-commit` hook running
`gitleaks git --staged --redact` (gitleaks 8.30.1 in nixpkgs).

- Must chain cleanly beside the existing `post-commit` symlink.
- Decide the false-positive escape hatch (`.gitleaksignore` or inline
  `gitleaks:allow`) — note both are themselves public.
- A full-history scan on 2026-10-16 (`gitleaks git ~ --redact`) found only
  the ISS-009 leaks; use it as the baseline.
