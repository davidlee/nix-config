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

## Preflight (2026-10-27)

No jail resolves or forwards a provider key. The `op run` wrapper needs
`gateway == null && useOpEnv && apiKeys != []`; `apiKeys` defaults to `[]`
(IMP-020) and no consumer sets it non-empty, nor passes `apiKeyOpRefs`.
Only this lib's tests build the wrapper. Consumers that still name the flags,
all no-ops: satan (`useOpEnv = false; apiKeys = []` on jailed-malebolge),
satan-corpus (`useOpEnv = false; passApiKeysFromEnv = true` in `mkJail`; its
jails have no keys and no gateway, so pi there has no provider). panopticon's
jail is on the gateway; only its devshell command still says `op run --`.

## Decisions (user, 2026-10-27)

- D1 Gateway only: remove `apiKeys`, `apiKeyOpRefs`, `useOpEnv`,
  `passApiKeysFromEnv`, the outer `op run` wrapper and the profiles'
  `useOpEnv`. Keep receipts: the removal is one isolated commit in
  `~/flakes`, named here, so `git revert <sha>` brings it back.
- D2 screwtape DEC-013's "lands in ~/dev/satan" is amended: the scanner and
  its op preset live in the agents lib; satan calls them.
- D3 satan's quotient input follows `github:davidlee/quotient` unpinned (with
  CHR-023's satan step).

## Plan (approved 2026-10-27)

Each step TDD red/green/refactor; `just test` green at the end of each.

1. satan-corpus onto the gateway: `mkJail` takes
   `gateway = jailLib.gatewayClient "pi"` (a behaviour change, its own
   commit there). panopticon's devshell runs `jailed-pi`, not
   `op run -- jailed-pi`.
2. The removal (D1), one commit: `jailed-agents.nix`, its tests (the op and
   pass-through cases go; a probe that no launcher carries `op run`
   stays), `agents/README.md` (§ Secrets via 1Password, the options table),
   the root README's "Jails not on the gateway" line, and the template's and
   `_SDLC`'s `gateway = null` fallback comments. A jail with
   `gateway = null` then has no provider path, by design. A consumer that
   still names a removed argument fails evaluation; strip the line when it
   bites (user, 2026-10-27): satan's jailed-malebolge `useOpEnv`/`apiKeys`,
   satan-corpus's two flags. Their jail drvPaths must not change (same
   lock; the flags were no-ops).
3. `agents/jail-scan.nix`: `mkJailScanCheck { name, launchers, literals,
   tokens, controlBind }`, satan's walker and positive control moved as is,
   plus an `opUnjailed` preset (satan's literals and tokens). Exported from
   the lib. Run the preset over this flake's test jails (in
   `checks.jailed-agents` or beside it).
4. satan: `op-unjailed` becomes the preset over its `jailPkgs`;
   `runner-socket-unjailed` a `mkJailScanCheck` call; its local walker goes.
   Both checks pass, and each still fails on its positive control.
5. Records: amend screwtape DEC-013 (D2); this card's known limits gain
   "posture parts in `RUNTIME_ARGS` (IMP-052) are seen as code, not as the
   paths they compute"; README § jail scan.

Then CHR-023: satan's form, satan-corpus and panopticon finish there.

## Progress

1. Done. satan-corpus `de38a66`: `mkJail` takes `gateway`; its launchers
   carry it. Live launch blocked by a pre-existing fault: `~/.emacs.d` is
   gone, so bwrap refuses every jail that binds it (ISS-019, seven repos).
   panopticon `a5b49ff`: `jpi` runs `jailed-pi`.
2. Done. **Receipt: `497d1f56`** (`git revert 497d1f56` restores the
   provider-key path). Red first: the tests assert `makeJailedAgent` has no
   `apiKeys`/`useOpEnv`/`passApiKeysFromEnv` and the lib no `apiKeyOpRefs`.
   The launch probe now refutes a session provider key anywhere bwrap sees.
   It bit only satan: `9c5d6a1` strips jailed-malebolge's two flags; satan's
   13 package drvPaths and devshell identical before/after on the same lock,
   satan-corpus's devshell identical. Every other consumer devshell
   evaluates against the new lib. `_SDLC` comments `5837f22`. `just gate`
   green.
