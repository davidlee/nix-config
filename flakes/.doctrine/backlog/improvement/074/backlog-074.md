# IMP-074: Declared jails in dev-envs: forwarderEntry split, ephemeralHome, hostIntegrations (nemesis:SL-026)

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

## Intent

nemesis:SL-026 PHASE-01 and PHASE-02, which land here. A project declares a
jail as data (`passthru.devEnv.jails`), and dev-envs builds it
(nemesis:DEC-235). Record chosen with the user (2026-11-21): a backlog item, not
a slice. The design is nemesis's, locked: `doctrine design show SL-026 -p
~/dev/nemesis`, §6 "Confinement" and §8 "Other repositories". Plan read at
nemesis 35e97d68 (plan.toml unchanged since 0c6c9c14). nemesis:PHASE-08 takes
over from here.

## Shape

```
stub-project devEnv.jails.probe
        │
dev-envs/dev-env.nix   jailErrors (validate, name the field) · mountArgs (bind words)
        │
dev-envs/flake.nix     declaredJail → jailLib.makeJailedPi {
                         profile offline, mountLaunchDir false, ephemeralHome,
                         hostIntegrations false, gateway, no doctrine,
                         extraOptions = envOptions ++ mountOptions ++ forwardOptions
                                        ++ set-argv --no-builtin-tools }
        │
agents/                socket-forwarder.nix forwarderEntry (readiness logic, once)
                       gateway-forwarder.nix = directory bind ++ forwarderEntry
                       jailed-agents.nix: ephemeralHome ? false, hostIntegrations ? true
```

- **Agents library (PHASE-01).**
  - `gateway-forwarder.nix` split. `socket-forwarder.nix` holds
    `forwarderEntry { socket; port; }`: the wrap-entry and the netns guard.
    `gateway-forwarder.nix` is the directory bind followed by it. The guard
    moved with the entry, since a forwarder in a networked jail would listen on
    the host's loopback whatever it relays. Its messages now say "socket
    forwarder" rather than "gateway forwarder". This is the one change existing
    offline-gateway launchers see.
  - `ephemeralHome`: no `persist-home`, so `~` is jail.nix's `--tmpfs ~`.
    Refused together with `persistedHome`.
  - `hostIntegrations = false`: `workspaceDepsFromEnv` forced off, no malebolge
    bridge, no zmx state relay, and posture's new `hostGitExcludes` flag off.
- **dev-envs (PHASE-02).**
  - `checkDevEnv` admits `jails` and validates each declaration. Its name must
    be bare and must not shadow dev-envs' own five jails. Known keys only.
    `agent` must be in the map (`pi`). `network` must be `"offline"`. Each
    mount needs `from` (relative and not climbing, or `$VAR[/path]`), `to`
    (absolute, `~` or `~/path`) and `mode` (ro/rw). Each forward needs an
    integer `port` and an absolute `socket`. `mounts` and `forwards` default
    to `[]`.
  - `noEnv` gains `jails = {}`.
  - `mountArgs` turns a mount into `--(ro-)bind "$PWD"/'rel' | "$VAR"'/rest'  "$HOME"'/rest' | '/abs'`:
    the literal parts are quoted, and the launcher expands the variables.
  - `innerOf` and `launcherOf` were lifted out of `checks.stub`, which now
    covers the declared jails too.

## ASM-005 (nemesis:ASM-005): holds

A launcher built with `unsafe-add-raw-args "--bind \"$PROBE_SESSION_DIR\" /session"`
(offline, `mountLaunchDir = false`) was launched with the variable set to two
fresh directories, one of them with a space in its name. Each directory
received the file the jail wrote at `/session/probe.txt`. With the variable
unset, the launcher refused: `PROBE_SESSION_DIR: unbound variable`, rc 1
(jail.nix launchers run under `nounset`). No fallback was needed. The result is
not recorded on nemesis's ASM-005; that is handed back.

## Verification (2026-11-21)

Red before each change, green after:

- `agents#checks.jailed-agents`: `declaredForward` (forwarderEntry alone: port
  and socket in the wrapper, no directory bind), `declaredForwardNetworkedFails`,
  `ephemeral` / `ephemeralPi` (tmpfs home, no `jail.nix/home`, `models.json`
  still bound), `ephemeralNamedHomeFails`. The existing forwarder behaviour
  tests (relay, early exit, exit status) pass unchanged.
- `agents#impureChecks.jailed-agents-env`: with `hostIntegrations = false`, a pi
  launcher has none of `/workspace/env-dep`, `/workspace/env-rw-dep`,
  `malebolge`, `-host-git-excludes-file` or `ZMX_SESSION`, and keeps its
  declared deps. The default carries all five markers. The fake pi is now a
  stub script, not `null`.
- `dev-envs#checks.dev-env`: 18 jail refusals, each naming its field; valid and
  minimal declarations admitted. Mount words are `eval`'d as the launcher would
  run them, and give exactly three words, including a `$VAR` value with a space
  and a literal `$` and `'` in `from`.
- `dev-envs#checks.declared-jail` (new, in `just test`): stub's `jailed-probe`
  has `--unshare-net`, the gateway socket bind, all four declared binds, pi's
  `--no-builtin-tools`, and two wrappers in its entry chain (4000 → gateway
  socket, 7000 → `/run/probe/duel.sock`). It has none of `/workspace`,
  `jail.nix/home`, malebolge, git excludes, `ZMX_SESSION`, doctrine,
  quotient, `GIT_AUTHOR_NAME` or postgresql. Mutation: `hostIntegrations = true`
  fails it on `malebolge`.
- `dev-envs#checks.stub` now loops over the declared jail as well.
- Every other agents and dev-envs check is green: quotient-relay,
  zmx-state-relay, jail-zmx-is-wrapper, dev-db, quotient-hostile-audit,
  project-pins, quotient-forms. treefmt, statix and deadnix are clean.
- Defaults unchanged: the drvPaths of dev-envs' five jails are identical when
  built against HEAD's agents library and against this one.
- Live, on Sleipnir: the real `jailed-probe --version` was run from a launch
  directory with `tools/probe/pi-mcp.json`, with `PROBE_SESSION_DIR` set and
  `$XDG_RUNTIME_DIR/nemesis-probe` present. It printed `1.6.0`. All mounts were
  bound and both forwarders reached readiness.

## Follow-ups

- SPEC-003 (dev-envs contract) now trails the code. Its `devEnv` schema table
  lacks `jails`, and it says a project "names no jail". It needs a revision
  (REV), not a direct edit.
- `dev-envs/flake.lock`: only `project` (the stub's narHash) was relocked. An
  un-overridden evaluation uses the pinned github agents, which lacks
  `forwarderEntry` until this is pushed and the input bumped. `just test`
  overrides it, as always.
