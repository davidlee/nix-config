# Implementation Plan SL-024: In-jail quotient for dev-envs: real server in the jail, delegates under the nested form family

Prose companion to `plan.toml`. Narrative only — no queried data lives here
(the storage rule); the phase list, criteria, verification, and links are
authored in the TOML. Use this for the plan's rationale and sequencing.
<!-- Reference forms: `lib:reference/glossary.md` § reference forms. -->

## Overview

Five phases, in the order the design's handover sets: forms, declaration,
consumer, proof, records. Each of the first three ends green under `just gate`,
and none of them changes what a jail does until PHASE-03 declares it.

```
PHASE-01 forms ──> PHASE-02 declaration ──> PHASE-03 dev-envs ──> PHASE-04 proof ──> PHASE-05 records
inert on host      off by default           jails change          real jail, human   docs, owed items
```

## Sequencing & Rationale

**Forms first.** Everything nested depends on them, and the change is inert on
the host, so it can land and be tested alone. It also creates
`agents/quotient-in-jail.nix`, which PHASE-02 fills out.

**Declaration before consumer.** The library argument is off by default, so the
fake-bwrap tests can settle ordering, registration and the refusals with no real
jail. PHASE-03 is then a small change whose risk is the lock, not the logic.

**Proof after the consumer.** The real-jail rows need the consumer built. These
rows carry what no reading settled: `set-argv` registration through the gateway
wrapper, real client startup, bind order, and the refusal on empty profiles.

**Records last.** Docs state what was proved, not what was expected. A failed
proof would otherwise leave them wrong.

## Notes

**Test access.** `jailed-agents-test.nix` imports `quotient-in-jail.nix` directly
for `policy` and `etcStoreBinds`, so `jailed-agents.nix` needs no new export. The key test runs `formArgs.secretEnv.LLM_GATEWAY_KEY`
through bash, using the existing stub of `mkFormFamily`.

**Not in the design's test list, added here.** The jail scan (`scannedJails`)
gains the `quotientServer` jails, so the new binds are scanned like every other
jail's.

**Launch home (departs from the design's wording).** The design says each real-jail
row starts from a fresh persisted home and that every row but form-probe runs in
the unmodified jail. The shipped `jailed-shell` cannot have both: a home is fixed
at build time by `persistedHome`, and changing it is a change to the jail. This
plan keeps the unmodified jail and uses its own home, `agent`, which never held
the spike's mounts and has no `.config/quotient`. That keeps the design's purpose,
no residue from the spike, and leaves the operator's live home in place.

**Empty profiles.** Moving the host's `~/.config/quotient/profiles` aside would
break every host delegation while it was gone. PHASE-04 instead runs quotient in
the jail against a scratch config directory with an empty `profiles/`, which
tests the same refusal. The `--ro-bind-try` itself is covered by PHASE-02's argv
test.

**The dev-envs lock and the published `agents`.** `dev-envs/flake.lock` pins
`agents` to a published revision, which has no `quotientServer`. `just test`,
`envrc/dev-envs.sh` and `bin/dev-envs-forms` all override `agents` to the tree, so
nothing here is affected, but a bare `nix build path:dev-envs#…` fails until the
library is pushed and that input re-locked. That is a post-push step for the
operator, recorded by PHASE-05.

**Re-locking.** Update only quotient, with no `--override-input`:
`dev-envs/flake.lock` must keep the stub as a relative path (`just test` refuses
otherwise).

**Spike diffs** in `research/raw/` are shape reference only; their hard-coded
workspace deps and probe home must not reach the shipped code.
