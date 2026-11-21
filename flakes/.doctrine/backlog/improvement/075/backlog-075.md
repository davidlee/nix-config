# IMP-075: Declared-jail check variants: jailed-<name>-check, launch-time gateway source (nemesis:SL-026 PHASE-02 EX-5)

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

## Intent

nemesis:SL-026 PHASE-02 EX-5, which lands here. It follows IMP-074 (6081428b,
EX-1..EX-4) and has the same record shape: a backlog item, not a slice. The
design and plan are nemesis's and locked. Plan read at nemesis f8f4bc7a.
Accepted wording (nemesis C-93; user, 2026-11-21): the contract gains
`hostIntegrations` plus a launch-time `runDirectory` word in the existing
`gateway` argument, used only by check variants. The jail vocabulary stays
closed. DEC-131 already records this.

Authority: `nemesis/.doctrine/slice/026/plan.toml` PHASE-02 EX-5 (the whole
criterion) and VA-1, and the three `[[variance]]` rows on C-93 in
`commitment-ledger.toml` (the latest narrows the others). Background: nemesis
RV-107 F-1, F-7 and F-14.

## Scope (EX-5, summarised; the plan text governs)

- Each declaration also yields `jailed-<name>-check`, from the same function
  and the same declaration. Both are flake packages. Check variants stay off
  `devShells.default`.
- `checkDevEnv` refuses a name ending in `-check`, naming it. A negative check
  declares `probe` and `probe-check` and expects the refusal.
- The check variant differs from production in two places only:
  1. Its entry runs the argv given at launch (a path in the jail), after every
     forwarder is ready, with pi's real entry appended as the last argument.
  2. Its gateway source can be chosen at launch, through the optional
     `gateway.clientDirectory` (§ Settled). Both of
     `JAIL_CHECK_GATEWAY_DIR` and `JAIL_CHECK_GATEWAY_KEY` set: use them.
     Neither set: the real gateway. One set, or a missing directory: refuse
     before bwrap, naming it. Only the host side of the offline profile changes
     (the preflight directory, and the source of the one bind to
     `/run/llm-gateway-client`). The in-jail destination, the forwarder's dial
     path and `runDirectory`'s meaning are unchanged.
- No production launcher contains a `JAIL_CHECK_GATEWAY_*` name; a check greps
  for them. With both variables set, production still binds the real directory.
- The five built-in jails' `drvPath`s are compared before and after (as
  IMP-074 did). Any difference is stated and justified here.
- `jailed-agents-test.nix`'s offline regression stays green (a custom literal
  `runDirectory` that the offline profile ignores; around l.864-878).
- A `just` recipe runs the live test on the host (not `checks` or
  `impureChecks`) with a fixture gateway socket, a dummy key, no real client
  directory, over `stub-project`'s `jailed-probe-check`. It covers each mount
  form, the ASM-005 two-run witness (both `$VAR` forms, one value with a space,
  each run's files only in its own directories), an unset source refusing,
  both forwards reaching fixture listeners, a stub model endpoint recording
  pi's first request, and both gateway refusals.
- Hand back to nemesis: the commit, the green check names, the live recipe's
  output, and the drvPath comparison.
- Afterwards: a small REV takes the `-check` refusal and the new checks into
  SPEC-003 (CHR-034's outcome, DEC-131's last consequence).

## Settled: one field, two meanings (was § Open)

Evidence:
- `agents/gateway-jail.nix:38-43`: in socket mode (offline profile) the
  preflight checks `dirOf clientSocket`, and `runDirectory` is not read.
- `agents/gateway-forwarder.nix:19` binds `dirOf socket` at the same path on
  both sides. The socket is `gateway.nix` `clientSocket`,
  `/run/llm-gateway-client/api.sock`.
- `agents/gateway.nix` `client`: `runDirectory = "/run/llm-gateway"`. That is
  the gateway service's RuntimeDirectory, a different directory. The doc at
  `jailed-agents.nix:585-589` gives it that meaning.

Inference: the check needs to replace the host source of the client-socket
directory. If `runDirectory` is used for that, the field means the gateway's
directory when it is a literal (and is ignored offline), but the host
client-socket directory when it is a `$` word on the offline profile. Its
meaning would depend on how it is spelled. The plan's escape hatch applies: "If
the library cannot take a launch-time `runDirectory` without a parallel input,
`/consult`."

Options:
- A. As planned: on the offline profile, a `$`-prefixed `runDirectory` is the
  bind source and preflight directory. Production is unchanged. One field gets
  two meanings.
- B. An optional fourth key in the same argument (for example
  `clientDirectory`), absent in production. It is still the existing argument
  and has one meaning, but nemesis may read it as "an input beside it".
- C. Offline, `runDirectory` always means the host's client directory. This
  needs `gatewayClient` to vary by profile, and it changes production drvPaths.

Outcome (2026-11-21): **B**, as `clientDirectory`, no rename. The user chose
it over A ("seems pretty janky"); nemesis accepted it as worded, with a new C-93
variance and EX-5's gateway clause rewritten (nemesis ad5b33d3). DEC-131's
choice, alternatives and consequences are amended to match.

- `gateway = { keyFile; url; runDirectory; clientDirectory?; }`;
  `clientDirectory` is absent in production.
- It is the host path of the relay's client-socket directory, a shell word
  expanded at launch as `keyFile` is: the one source of the offline preflight
  and of the source side of the bind to `/run/llm-gateway-client`.
- The library refuses it on a profile with network.
- `runDirectory` keeps its one meaning and is still not read offline.
- Only `jailed-<name>-check` sets it, from `JAIL_CHECK_GATEWAY_DIR`.

Correction to C above (inference, unverified): the strings reaching the scripts
would likely be the same, so drvPaths might not change; it was rejected on
meaning, not on drvPaths.

## Settled: entry order (consult, 2026-11-21)

Evidence: jail.nix's `wrap-entry` makes each later wrap enclose the earlier
ones. `makeJailedAgent` adds `gatewayJail.options` (and the offline gateway
forwarder's wrap-entry with it) before `extraOptions`. A check wrap that
dev-envs adds through `extraOptions` would therefore run before the gateway
forwarder is ready, which breaks EX-5's "after every forwarder is ready".

Outcome: **X**, chosen by the user over a new library entry hook (Y, which
contradicts C-93's "no new makeJailedAgent option") and over letting the check
argv run before the gateway forwarder (Z, which breaks EX-5). This is internal
to the library: the gateway forwarder's wrap-entry is applied after
`extraOptions`, so it is the outermost wrap. The socket-directory bind and every
bwrap argument keep their place. The five built-in jails are on a networked
profile, so they carry no forwarder, and their drvPaths are expected to stay the
same. `jailed-probe` and the offline test launchers change their wrapper order:
the gateway forwarder is now ready before the declared forwards.

## Delivered

- `dev-envs/dev-env.nix`: `jailErrors` refuses a name ending in `-check`.
  `dev-env-test.nix` declares `probe` and `probe-check` and expects the refusal.
- `agents/gateway-forwarder.nix` now returns `{ bind; entry; }`, and takes an
  optional `source` for the host side of the bind. `gatewaySocketOptions` is
  `bind ++ entry`, unchanged for its callers.
- `agents/gateway-jail.nix` takes `clientDirectory`, which is optional and
  allowed in socket mode only. With network it is an evaluation error. It is
  the preflight directory (tested inside double quotes, as `keyFile` is) and
  the bind source. It returns `entryOptions`, which `makeJailedAgent` applies
  after `extraOptions` (§ Settled: entry order).
- `dev-envs/flake.nix`:
  - `declaredJail {check}` builds both variants from one declaration.
  - The check variant adds `checkEntry`, the innermost wrap. It runs the launch
    argv with a script appended last; that script holds pi's real entry and
    its flags.
  - The check variant sets `checkGateway`: `keyFile` and `clientDirectory`
    become `${JAIL_CHECK_GATEWAY_KEY:-<real>}` and
    `${JAIL_CHECK_GATEWAY_DIR:-/run/llm-gateway-client}`, and nothing else
    changes.
  - `checkJail` puts a guard in front of it: both variables or neither.
  - `checkJails` are flake packages only. `shellPackages`, now hoisted into the
    `let`, leaves them out, and an `assert` in `checks.check-variant` holds
    that.
- `justfile`: `test` gains `check-variant`. A new recipe,
  `declared-jail-live`, runs `dev-envs/declared-jail-live` with its in-jail
  entry `declared-jail-live-entry`.
- `agents/README.md`, and the `gateway` doc in `jailed-agents.nix`: they
  describe `clientDirectory` and the wrap order.

## Verification

- Red, then green:
  - the `-check` refusal (`checks.dev-env`: "FAIL jail name ends in -check",
    then green);
  - the library cases (`checks.jailed-agents`: the shape refusal, then green;
    `clientDirGateway`, `clientDirNetworkedFails`, `offlineGatewayForward`);
  - `checks.check-variant` (an evaluation error with no `checkJails`, then
    green).
- The offline regression (`offlineGateway`, a literal `runDirectory` the
  offline profile ignores) passes unchanged in `checks.jailed-agents`.
- The production grep: `checks.stub` refuses `JAIL_CHECK_GATEWAY_` in every
  production launcher and its inner launcher, the declared `jailed-probe`
  included. The production bind is the literal
  `--ro-bind /run/llm-gateway-client /run/llm-gateway-client`
  (`checks.declared-jail`). Because production text names no
  `JAIL_CHECK_GATEWAY_*` variable, setting both cannot change its mount table.
  That is inferred from the text; I did not run it live.
- drvPaths (`drvpaths-before.txt` and `drvpaths-after.txt` here):
  - The five built-in jails are identical.
  - `jailed-probe` changed from `px15nz9d…` to `3m1j6bky…`. Justification:
    the gateway forwarder's wrap now comes after the declared forward's (§
    Settled: entry order). The value already appeared after the library edit
    alone, and the dev-envs edit left it unchanged.
- Live (`just declared-jail-live`, Sleipnir, 2026-11-21): all checks passed.
  The output is in `declared-jail-live.txt` here.
- `just test` passed (exit 0). Among its checks:
  - agents: `jailed-agents`, `quotient-relay`, `zmx-state-relay`, and the
    impure `jailed-agents-env`;
  - dev-envs: `stub`, `declared-jail`, `check-variant` (new), `dev-env`,
    `dev-db`, `quotient-hostile-audit`, `project-pins`, `quotient-forms`;
  - root: `features`, `factories`, `host-meta`, `templates`, `workarounds`,
    `llm-gateway`, `satan-room`, `quotient-forms`, and the script tests.
- `treefmt` (statix, deadnix) and `shellcheck` on both new scripts are clean.
  `doctrine validate` is clean.
- A fix from before this work: `templates-test.nix` still called
  `devEnv.errors` without the `jailAgents` and `reservedJails` that IMP-074
  added, so `checks.templates` failed at evaluation. It now passes them,
  empty, because the template declares no jails.

## Follow-ups

- SPEC-003 REV: the `-check` refusal, the check variants as flake packages,
  `checks.check-variant` and `just declared-jail-live` (DEC-131's last
  consequence; precedent REV-023).
