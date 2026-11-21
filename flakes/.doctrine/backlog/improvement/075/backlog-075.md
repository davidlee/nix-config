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
  2. Its gateway source can be chosen at launch. Both of
     `JAIL_CHECK_GATEWAY_DIR` and `JAIL_CHECK_GATEWAY_KEY` set: use them.
     Neither set: the real gateway. One set, or a missing directory: refuse
     before bwrap, naming it. Only the host side of the offline profile changes
     (the preflight directory, and the source of the one bind to
     `/run/llm-gateway-client`). The in-jail destination, the forwarder's dial
     path and every other caller's literal `runDirectory` are unchanged.
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

## Open: one field, two meanings (consult before building)

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

Not decided. Settle it with the user (and nemesis, since it is the C-93
wording) before writing the library change.
