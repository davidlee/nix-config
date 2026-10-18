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

## Oubliette connection (2026-10-17)

Speculative. Oubliette (`~/dev/oubliette`) solved the same problem for
firecracker capsules, but by working on a separate copy rather than through
a broker. The guest works in its own clone. The host starts every transfer:
`capsule-provision` pushes history in, `capsule-collect` fetches work out
into a host-side quarantine repo, and promotion into the real repo is a
human step (`host/git-channel.nix`; oubliette `docs/ledger/018-git-channel-direction.md`,
item 18). The guest holds no git authority at all.

The same shape could serve a bubblewrap jail. Instead of brokering git
operations on a shared host repo, give the jail its own clone and fetch from
it into a quarantine repo. Oubliette's Plan B
(`docs/plan-b-other-jails.md`) already notes the channel is "two ordinary
programs that take a URL", and that a sandbox on the same host makes the URL
a local path.

Trade-off to weigh: a broker keeps the jail on the live worktree (direnv,
editor, no sync step); a clone with a quarantine moves work through a fetch
and a promotion. If that is preferred, the channel is a candidate to share
along with the gateway (IDE-008).
