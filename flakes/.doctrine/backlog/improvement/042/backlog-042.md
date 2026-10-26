# IMP-042: Jail launcher should refuse a launch dir that is $HOME or an ancestor of it

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

## Problem

`agents/jailed-agents.nix` `launchDirOptions`: with the launch dir mounted,
the launcher binds `$PWD` read-write at `/workspace/<basename>`. Jails run as
the operator's uid, so a jail launched from `$HOME` (or `~/.local`,
`~/.config`, `~/.local/state`) can read and write everything below it:
- mail copies (Gnus `~/Mail`, Thunderbird, screwtape's store in
  `~/.local/state/screwtape`);
- `~/.config/systemd/user` and shell rc files, i.e. code that later runs
  unjailed (an escape; inferred, not reproduced).

The jail's own `$HOME` is a persisted directory under the agents user, so
this only bites through the launch-dir bind.

## Existing guard (2026-10-26)

`~/nushell/mod/pi-dev/mod.nu` `jail` already refuses a cwd that is `$HOME`
or an ancestor of it (`$home | str starts-with $cwd`). Remaining gaps:
- descendants of `$HOME` that contain sensitive state: `~/.local`,
  `~/.local/state` (screwtape's store), `~/.config` (user units, rc-adjacent
  config);
- the `jailed-agents.nix` launchers, which bind `$PWD` with no guard at all.

## Proposal

Apply one guard on every jail entry point (the pi-dev `jail` and the
`jailed-agents.nix` launchers): refuse a mounted launch dir that is `$HOME`,
an ancestor of it, or a sensitive subtree's root or anything inside it
(`~/.config`, `~/.local`, `~/.ssh`), with a clear message.

## Origin

screwtape RV-001 F-27 (SL-001 design review, 2026-10-26): screwtape's
invariant I7 ("jails can't see the store") holds only under its launch
condition: a jail's working directory must not be, or contain, the store
directory (`~/.local/state/screwtape`), the credential directory
(`~/.config/credstore.encrypted`) or `~/.config/systemd/user`. The operator
accepted that condition and asked for this guard rather than a deployment
gate. Related:
satan ISS-028 (wider jail bypasses).
