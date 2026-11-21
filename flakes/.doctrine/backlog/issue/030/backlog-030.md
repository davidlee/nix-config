# ISS-030: Jails inherit the caller's open file descriptors past the mount allowlist

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

Source: hand-back from nemesis SL-026 PHASE-08 (RV-110 F-6), 2026-11-22.
Nemesis works around it in its own launcher (`~/dev/nemesis/tools/probe/launch.sh`);
the defect is in the launcher chain `agents/jailed-agents.nix` generates.

## Observed by nemesis (verified there, nix-config `fcb1c787`)

- `jailed-probe-check … 7< <host file>`: inside the jail `/proc/self/fd/7`
  pointed at the host file, and it was readable. No mount refers to it, so an
  inherited fd is a channel past the mount allowlist.
- fd 63 (the `--args` process-substitution pipe) was also open inside, drained.
- bwrap runs without `--new-session`. TIOCSTI (terminal input injection) is
  blocked only because this host sets `dev.tty.legacy_tiocsti = 0`.

## Confirmed here (by reading the built launcher, not by running a jail)

`jailed-eca`'s inner launcher (`/nix/store/96n2…-jailed-eca/bin/jailed-eca`)
opens `RUNTIME_CLOSURE_BIND_ARGS_FD` (a store file) and fd 22 (the gateway-key
pipe, DEC-049), then `exec bwrap …` with no fd closing. So every jail from
`makeJailedAgent` inherits whatever its caller held open, plus those two fds.

`no-new-session` is a deliberate base option (`jailed-agents.nix:280`,
README "Sandbox defaults"), so `--new-session` is a design choice to revisit,
not an omission.

## Proposed fix (from the hand-back; not yet designed)

- Before `exec bwrap`, close every fd above 2 except those bwrap is told to
  read (the `--args` fds). Do not put a redirection on the closing loop: bash
  then keeps a saved copy of an fd alive (seen as fd 10 in nemesis).
- Optional: pass `--args` through a file, so no drained pipe stays open.
- Weigh `--new-session` against job control and Ctrl-C in interactive
  harnesses (pi, claude, codex, eca).

## Proposed test

A runtime check like `declared-jail-live` (flake `checks` cannot run bwrap):
start a jail with `7< <sentinel>` and an entry that lists `/proc/self/fd`;
fail if any fd other than 0–2 leads to a host file, a socket, or a pipe that
still holds data. Include a control without the fix to show the check
catches the leak. Nemesis's equivalent: `tools/probe/confine/check.sh`,
`tools/probe/confine/verdict.ts` (`fdViolations`), `run.sh` ("control: a
descriptor inherited past the launcher").

## Owed back to nemesis

Tell nemesis if the jails' fd contract changes (for example, a jail starts
passing an fd on purpose): its `fdViolations` admits only stdio, the entry
script and drained pipes.
