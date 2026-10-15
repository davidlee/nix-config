# POL-001: Public home repo: no secrets, classified identifiers

## Statement

Every tracked path under `~` is public. Pushing publishes it to
`github:davidlee/nix-config`, and history is permanent: a secret that was
ever pushed is compromised, whatever is deleted later.

1. **Never commit a secret.** Passwords, API keys, tokens, OAuth state,
   private keys, encryption secrets, session cookies, shell history, app
   state databases. This holds for Nix expressions too: the Nix store is
   world-readable. Secrets are resolved at runtime (1Password `op`; later
   sops-nix / agenix).
2. **Classify identifiers before committing them** (table below). Never and
   Private stay out; Public is fine; Unsure is asked.
3. **Stage explicitly.** Name paths. Never bare `git add -A` at `~`. Read
   `git diff --cached` before every commit. An agent asks the user before
   tracking any new path outside `~/flakes`.
4. **Least privilege for secrets at runtime.** A process receives a secret
   only if it needs it. A jailed agent gets only the keys its own provider
   uses.
5. **Logs and transcripts are secret-bearing.** Agent transcripts, session
   logs and tool output are never tracked, synced or shared.
6. **On a leak, rotate first.** Revoke or regenerate the secret at once;
   rewriting history is secondary and optional.

### Classification

| tier | rule | examples |
|---|---|---|
| Never | hard block; scanner-enforced where possible | anything in rule 1; private personal details (health, finances, relationships, correspondence) |
| Private | kept out of the repo, via a private input (IMP-002) or an untracked file | DNS-filter profile ids (ControlD), tailnet names, work identity (work email, employer-internal hosts and repos) |
| Public | fine to commit | the personal commit email, LAN and printer addresses, host names, `op://` refs (vault and item names) |
| Unsure | ask the user before committing | anything not covered above |

The user's answer settles an Unsure case; add the example to this table.
This file is itself public: describe Private items by category, or point at
the untracked file that holds them (e.g. `~/.config/zsh/work.identity.zsh`);
never write the value here.

## Rationale

`$HOME` is the worktree of a public repo (`~/.git` → `~/.cfg`,
`showUntrackedFiles = no`). One mistaken `git add` publishes anything in
`~`. Two credentials have already leaked this way (ISS-009), and API keys
have surfaced in agent transcripts (IDE-005). Identifiers need judgement,
not a blanket ban: some are harmless, some aid targeting or link
identities.

## Scope

Every path tracked by the `~` repo, its history, and every branch pushed to
the remote. Rules 4 and 5 also cover runtime secret handling in this repo's
code (`agents/`, `features/`, `modules/`), whether or not its output is
tracked.

## Verification

- Agent review of each staged diff (rule 3) — today's only gate.
- Pre-commit secret scan (IMP-021), once landed.
- Periodic full-history scan: `gitleaks git ~ --redact`.
- Least-privilege keys for jailed agents (IMP-020).

## References

- IMP-002 — private flake input for host-local identifiers
- IMP-020, IMP-021, IDE-003, IDE-004, IDE-005 — enforcement and hardening
- ISS-009 — historical leaks
- `mem.system.flakes.home-worktree` — the `$HOME` worktree hazards
