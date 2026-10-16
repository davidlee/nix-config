# IDE-004: Brokered git for jailed agents

Jails expose the raw `git` binary (wrapped only by `agents/git-guard.sh`,
which refuses work-discarding subcommands). Instead, broker git operations
through a host-side wrapper, so a jail never holds authenticated git
capability (credentials, push) and policy is enforced outside the jail.

- Harness-agnostic, like IDE-003; may share its broker.
- Builds on `git-guard.sh` and the existing `blockSshGitPush` controls.

**Scope note (2026-10-16):** this applies to bwrap jails, which share host
repos. The SATAN proposal VM (satan IDE-007) doesn't need it: its clones live
inside the guest (Firecracker has no shared folders), plain git there can only
damage the guest's own copies, and the host starts every transfer, so the
guest holds no git authority at all.
