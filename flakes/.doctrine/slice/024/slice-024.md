# In-jail quotient for dev-envs: real server in the jail, delegates under the nested form family

## Context

DEC-122 point 6 names in-jail quotient as the route for single-repo delegation
from jailed claude, once quotient:IDE-008 lands. quotient:DEC-071 settles the
shape and binds this design: in-jail quotient is a jail configuration. A real
server runs in the jail, delegates run under the existing form family nested in
it, and the jail definition supplies a read-only policy. No relay, no new form
type, no reading of `unconfined`.

quotient:DEC-071, in short:

1. Write reach stays form-1's: root, session directory, private temp, exposure.
2. A jail uses the existing family with its narrow read view.
3. Policy and profiles are generated into the store and bound read-only at
   `~/.config/quotient`. Ceilings are defaults: they bind delegates of the
   registered server, not the orchestrator.
4. Roots are `["/workspace"]`; the jail's mounts are the limit.

Protection binds delegates only. This is not an adversarial boundary; the host
relay stays the answer where controls must bind an untrusted agent.

Evidence: quotient:IDE-008 § Probes (`doctrine show IDE-008` in `~/dev/quotient`).
Those probes were scratch, on the host's machine family. None of them ran the
per-project dev-envs family.

## Scope & Objectives

1. **Key source.** `quotientFormFamily` reads the gateway key from
   `$HOME/.config/llm-gateway/keys/pi`, absent in a jail, which holds only
   `LLM_GATEWAY_KEY`. Fatal today. Forms must take the key in both places.
2. **Closure.** The forms, bubblewrap (through the forms' closure) and a real
   quotient are in the jail's closure. dev-envs' quotient pin moves from v0.6.0
   to v0.6.1, matching the root flake.
3. **Policy** in the store, bound read-only at `~/.config/quotient` after the
   persisted home. `roots: ["/workspace"]`, forms by store path. **Profiles** are
   the host's directory, bound read-only inside it (operator, 2026-11-05; departs
   from quotient:DEC-071 point 3, which says store-generated).
4. **Registration.** Operator, 2026-11-05: the library declaration stays off;
   dev-envs registers quotient by default in `jailed-claude` and `jailed-codex`.
   `jailed-shell` carries the same closure unregistered, as the test bed and for
   `quotient reduce`. `jailed-pi` and `jailed-pi-research` are unchanged.
5. **DEC-122 note**: in-jail roots are limited by the jail's mounts.
6. **satan's `pi-report-test.sh` section 1** runs in a jail with real quotient.
7. **`/etc` binds** (DEC-125). With no store database, `quotientFormFamily` binds
   the store targets of the links under `/etc/{hosts,nsswitch.conf,resolv.conf,ssl}`,
   so a nested form has TLS, hosts and nsswitch.

Proof, all in a real jail (`jailed-shell`, not bare bwrap):

- `scripts/hostile-audit`, and `scripts/form-probe` with its `nix` stand-in
  (DEC-127)
- the `read` family form, nested
- a per-project dev-envs family
- direct TLS from a delegate
- the launcher's `nix-store` "path … is not valid" lines: harmless with the
  `/etc` binds (DEC-125)

## Non-Goals

- quotient:IDE-009 (per-root capability) and IDE-010 (cross-root delegation jail).
- The relay: it stays dormant, and `quotient` on `makeJailedAgent` keeps meaning it.
- quotient changes. A check that needs one (most likely in `mkFormFamily`) stops
  this work and is raised in quotient rather than worked around.
- quotient's docs. quotient:IDE-008 stays open until they land from what shipped.
- `quotient allow` in a jail: the store is unwritable, so machine forms only.

## Summary

Affected surface:

| path | change |
|---|---|
| `agents/jailed-agents.nix` | key source; `/etc` binds; `quotientServer` on `makeJailedAgent` |
| `agents/quotient-in-jail.nix` (new) | policy, profiles, bind, registration |
| `agents/jailed-agents-test.nix` | behaviour tests |
| `agents/README.md`, `README.md` | routes table, mechanics |
| `dev-envs/flake.nix`, `dev-envs/flake.lock` | pin, wiring into the jail set |
| `.doctrine/spec/tech/003/` | SPEC-003, if the jail set's contract moves |
| `.doctrine/knowledge/` DEC-122 | the note |

Facts established while scoping (observed, 2026-11-05):

- quotient's `childEnv` passes the server's environment to the form minus
  `QUOTIENT_*` and evidence paths, so `LLM_GATEWAY_KEY` reaches the launcher if
  the client passes it to the server.
- `.config/quotient/profiles/*.md` are tracked in the home repo but sit outside
  `flakes/`, so no flake can read them.
- `quotient` on `makeJailedAgent` is the relay, so this needs another name.
- `outerGit` is inert in a nested form: its guard needs `${PWD%/*}` to equal
  `$HOME`, and a jail's launch dir is under `/workspace`. Delegates rooted at
  `/workspace/flakes` get no git.
- Claude Code 2.1.310 has `--mcp-config`, per launch and not persisted.

Risks:

- **A logged-in delegate call.** The client probes used an environment-dumping
  stand-in server, and real quotient was driven from Node, so neither claude nor
  codex has started it, and a full call from either is unproven. Probe results are in
  `research/research.md`.
- **Re-approval.** A key-source or pin change gives every dev-envs form a new store
  path, so each project with approved forms needs `quotient allow` again.

Closure intent: every proof item above passes in a real jail, with output recorded
in slice notes; `just test` and the gate are green; DEC-122 and `agents/README.md`
state the result.

## Follow-Ups

- quotient:IDE-008's docs, from what ships here.
- A quotient backlog item: an unmodified form-probe run in a jail, through a
  prebuilt-family mode (DEC-127).
- A note on quotient:DEC-071 point 3: profiles here are the host's (DEC-126).
