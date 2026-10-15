# IDE-004: Brokered git for jailed agents

Jails expose the raw `git` binary (wrapped only by `agents/git-guard.sh`,
which refuses work-discarding subcommands). Instead, broker git operations
through a host-side wrapper, so a jail never holds authenticated git
capability (credentials, push) and policy is enforced outside the jail.

- Harness-agnostic, like IDE-003; may share its broker.
- Builds on `git-guard.sh` and the existing `blockSshGitPush` controls.
