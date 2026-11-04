# IMP-065: Jails and forms: bind a repo's git hooks and config read-only

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

## Context

A jail binds the launch directory read-write, `.git` included. An agent that can
write `.git/hooks/*` or `.git/config` (`core.fsmonitor`, `core.sshCommand`,
aliases, filter drivers) gets code run on the host the next time the operator
runs git there. The risk is already accepted for every project; it is cheap to
remove.

Surfaced by IMP-057, where the git dir is `~/.cfg` (the whole dotfiles history).

Status (2026-11-04): IMP-057 does not subsume this. It mounts `.cfg` read-only
by its own `.cfg`-specific option, so this item stays open for ordinary repos,
rescoped by § Review below from "remove" to "narrow".

## Proposal

In the jail library (and so in every dev-envs jail and quotient form), overlay
`<gitdir>/hooks` and `<gitdir>/config` read-only after the read-write launch-dir
bind. Objects, index and refs stay writable, so commits work. bwrap mounts in
argv order, and runtime args follow every static one, so
`--ro-bind-try … ` as `RUNTIME_ARGS` (off the bwrap line, per IMP-052) suffices.

Check for other host-exec surfaces: `config.worktree`, `info/attributes` (inert
without a config-defined filter), `objects/info/alternates`.

## Cost to weigh

A read-only `config` blocks operations that write it (`git remote add`,
`git branch -u`, `git switch -c` with upstream tracking, `git submodule`).
Accepted: remote interactions are already best-effort blocked system-wide, so
the cost is small. Confirm no routine local-only operation writes `config`.

## Review (2026-11-04, from IMP-057)

Probed with plain bwrap on scratch repos, with a benign `core.fsmonitor` payload.
The overlay narrows this surface; it does not remove it.

| route | result on the host |
|---|---|
| direct write to `config` | refused |
| `mv .git`, recreate it with a new `config` | **ran**: the overlay guards the path, not its parent. Binding `.git` as its own mount refuses it (EBUSY) |
| write `.git/commondir` naming a planted dir | **ran**, past a read-only `config`, on `git status` |
| nested repo in the worktree, operator's git run inside it | **ran**; no git-dir write needed |
| gitlink for that repo in the index, `git status` from the parent | **ran** |
| untracked nested repo, `git status` from the parent | did not run |

- `hooks/` is already dead here: the global `core.hooksPath` disables every
  repo's `.git/hooks` (observed). A repo `config` could re-enable it, which is
  why `config` matters and `hooks/` does not, on this host.
- `info/attributes` is not inert by the stated rule: the global
  `diff.lockb.textconv = bun` is a config-defined driver. `bun` is not on the
  host PATH, so inert in practice; a worktree `.gitattributes` reaches it too.
  Not probed.
- `config.worktree` needs `extensions.worktreeConfig`, set in `config`
  (from git's documentation, not probed). `objects/info/alternates` redirects
  objects, not execution (same basis).
- Closing `commondir` needs a real file on the host holding `.`: an absent file
  cannot be overlaid without creating one, and git dies on an empty one (from
  git's source, not probed).

The nested-repo routes need only a writable worktree, so no git-dir overlay can
close them. Reconsider the card's "cheap to remove" before building it.
Only refusing host git in jail-written trees would address those.

Related: IMP-057, IMP-042, IMP-052, SPEC-003.
