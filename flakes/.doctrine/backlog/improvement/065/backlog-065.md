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

Related: IMP-057, IMP-042, IMP-052, SPEC-003.
