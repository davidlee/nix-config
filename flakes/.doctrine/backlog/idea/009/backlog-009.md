# IDE-009: Thin scripted bwrap jail for ad-hoc agents, with opt-in exposure flags

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

A launcher script (iterated in nushell, not the flake) that wraps an
unjailed agent — first `pi`, aliased `pi-dev` — in a thin bubblewrap jail.
It is not a project jail: the scope is cwd at launch, the toolset is the
host's. The aim is only to rule out the worst outcomes on this machine.

Origin: 2026-10-20 session, while scoping a system-wide `pi` feature. The
library jails (`agents/jailed-agents.nix`) fix a toolset and profile at build
time; this is the ad-hoc complement.

## Defaults

```
$HOME     read-only, except cwd and the agent's config dir
hidden    ~/.ssh  ~/.gnupg  ~/.config/op  ~/.config/llm-gateway/keys/*
          (all but the jail's own key)  /run/user/$UID/{gnupg,ssh-agent,bus}
env       GIT_CEILING_DIRECTORIES=$HOME
          PI_CODING_AGENT_DIR=<discrete dir>   (pi 0.99.1 reads it; also
          PI_CODING_AGENT_SESSION_DIR — names found in the build, untested)
sudo      none: --unshare-user, no setuid inside
network   on (the agent needs it); or gateway socket only
```

`~/.cfg` is the main hazard: `$HOME` is the worktree of the home repo, so
`git stash -u` / `git clean` / `reset --hard` run under `~` act on all of it.

## Opt-in flags (`--with a,b,…`)

| flag | binds | note |
|---|---|---|
| `ssh` | `$SSH_AUTH_SOCK`, `~/.ssh/{config,known_hosts}` ro | push without key material in reach; not `~/.ssh` itself |
| `dbus` | session bus socket | grants `systemctl --user` — nearly no jail. Notifications only: filter with `xdg-dbus-proxy` to `org.freedesktop.Notifications` |
| `cfg` | `~/.cfg` rw | needed to commit from `~/flakes` (below) |

## Git: does hiding the home repo break commits?

Tested 2026-10-20 in a scratch layout copying this one (a parent whose
`.git` file points at a missing gitdir, a normal repo nested inside):

| where the agent runs | home gitdir hidden | result |
|---|---|---|
| repo with its own `.git` (`~/dev/foo`) | — | works; discovery stops at the nearest `.git` |
| subdir of `~` with no repo of its own (`~/flakes`) | yes | `fatal: not a git repository: (null)` |
| same, `GIT_CEILING_DIRECTORIES=$HOME` | either | clean refusal: `not a git repository (or any of the parent directories)` |
| any repo, gitdir read-only | — | `Unable to create '.git/index.lock': Permission denied` |

Decision (user, 2026-10-20): for `~/flakes`, bind `~/.cfg` rw (`--with cfg`)
while the rest of `$HOME` stays ro except cwd. A destructive git op then
cannot touch files outside cwd; it may still rewrite refs and the index,
which the reflog recovers unless the agent also runs `gc` / `reflog expire`.

Not handled: linked worktrees, whose gitdir lies in the main repo's
`.git/worktrees/<name>`, outside cwd. Unused for `~`, rare elsewhere; if
needed, bind `git rev-parse --git-common-dir` rw.

Related: IDE-004 (brokered git for jailed agents) — a broker would remove
the need for `--with cfg`.
