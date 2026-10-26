# IMP-051: Agents lib owns the jail-scan checks: op-unjailed and the launcher walker move upstream from satan

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

## Context

satan's `flake.nix` now carries `jailScanCheck` (screwtape SL-001 PHASE-08,
DEC-013): a text check over built jail launchers (satan DEC-046) that walks
each launcher through the scripts it execs, its `{FD}</nix/store/…` bind-args
files (NUL-separated) and the nested `-jailed-*` launchers on its PATH, and
fails on forbidden literals or bare-argument path tokens. Each instance runs a
built-in positive control (a synthetic launcher binding through an args file)
and fails on zero scripts scanned. Two instances use it:

- `op-unjailed`: no `/run/wrappers/bin/op`, `onepassword-cli`, `.1password`,
  `1Password-BrowserSupport.sock`, `1PASSWORD_SDK_INTERGATIONS`, nor a bind of
  any ancestor (`/`, `/run`, `/run/wrappers`, `/run/wrappers/bin`,
  `/run/user`, `/run/user/<uid>`, `$XDG_RUNTIME_DIR`).
- `runner-socket-unjailed`: satan-specific (`satan-runner`, `/run/user/<uid>`).

Its scanned values belong to this lib: `jailed-agents.nix` is where the op
wrapper and every bind come from, so a regression lands here first.
`jailed-agents-test.nix` `gateway_probes` already refuses
`/run/wrappers/bin/op` for gateway-mode launchers.

## Proposal

1. Port the remaining `useOpEnv` consumers to the gateway and remove
   `useOpEnv` and the op outer wrapper (operator, 2026-10-27: opEnv is
   superseded by the gateway). Until then the walker would flag the host-side
   `op run` outer wrapper, which is legitimate.
2. Export the walker/scanner from the agents lib (e.g.
   `mkJailScanCheck { name, launchers, literals, tokens, controlBind }`) and an
   op preset; run the op preset over this flake's own test jails.
3. satan consumes both: `op-unjailed` becomes a call with its `jailPkgs`;
   `runner-socket-unjailed` stays in satan as a call to the shared scanner.

## Known limits (carry over)

A guard for known paths, not proof of SPEC-002 NF-004: indirection
(`B=/run; --bind "$B"`), runtime-generated args (`elf-closure-binds`,
`printf` process substitutions), helpers not named `-jailed-`.

Related: IMP-045 (refactor pass over the jail library), satan ISS-028, RSK-021.
