# IMP-045: W2 — Refactor pass over the agents jail library

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

Programme W2. `agents/jailed-agents.nix` is 843 lines (test 770). A cohesion
and coupling pass, done alongside or just after W1 (IMP-044) so the ro/rw work
lands in clean code.

Known debris:
- `agents/jailed-agents-refactor.local.md` — a handover that still refers to
  the old `pub/` layout; decide whether any of it is live, then drop it.
- `agents/examples/go-project` — predates the gateway.
- the handover's deferred items: split the module, merge the two profile maps,
  reduce maker boilerplate, rationalise `commonPkgs`.

Related: CHR-020 (tech spec for the jail library), IMP-036 (jail test
helpers), IMP-042 (refuse `$HOME` launch dir).

Followed by IMP-051 (jail-scan checks move upstream from satan; `useOpEnv`
and the op outer wrapper removed), which edits the same module.

## Plan (agreed 2026-10-27; no slice)

The user waived a slice: this is a refactor that keeps behaviour, already
under test. Work it as a series of commits on this card. After each step:
`just test` green, `just gate` (treefmt: alejandra, statix, deadnix) clean,
consumer drvPaths unchanged (below), and a progress note here.

Findings this plan comes from (read of `jailed-agents.nix`, plus a consumer
grep over ~/flakes, ~/dev, ~/.config/emacs, ~/satan-corpus, ~/notes):
- the handover's five phases are all in the code; only its deferred list is
  still open, and this card already copies it.
- `blockGitPush` (alias of `blockSshGitPush`) and the `commonPkgs` export
  have no consumers.
- `profileDefaults`: `blockSshGitPush`, `guardGit` and `exposePostgres` have
  the same value in every profile; `profiles.*.options` is `[]` in every
  profile.
- the 11 maker functions are one 9-line pattern.
- in `makeJailedAgent`, the workspace binds (about 70 lines) and the gateway
  part (about 60 lines plus its wrapper) are self-contained. Leave the
  `op run` secrets part alone: IMP-051 deletes it.

Steps:
1. Delete: `jailed-agents-refactor.local.md`, `examples/go-project` and the
   README link to it, the `blockGitPush` alias and its test, the
   `commonPkgs` export.
2. Merge `profiles` and `profileDefaults` into one map: `network`, `home`,
   `sandboxGitIdentity`, `useOpEnv`. The invariant booleans become plain
   argument defaults; `options` goes.
3. Generate the `makeJailed<Name>` makers from one name-to-agent map; the
   exported names stay the same.
4. Extract the workspace binds into a pure function in its own file, then the
   gateway part likewise.
5. Smaller items: a `refuse` helper for the checks block; a header comment
   that leads with gateway mode; refuse a `name` that starts with `jailed-`
   (satan-corpus's `jailed-jailed-pi-emacs`; that consumer is fixed in
   CHR-023); fold `packageManagerOptions` in and drop its TODO.

Out of scope: `unjailed`/`agentsByName` duplication (pick one during
CHR-023), `/run/user/1000` in `satanMcpOptions`, blocking pushes over HTTPS.

Consumer baseline: drvPaths recorded before step 1. Steps 1–4 and step 5's
comment and helper changes must reproduce them exactly. The comparison is
`nix eval --impure --raw <flake>#<attr>.drvPath --override-input agents
path:~/flakes/agents` for:
- org-incremental-writing: `packages.x86_64-linux.jailed-{claude,codex,pi,pi-research}`
- ~/.config/emacs: every `packages.x86_64-linux.*`
- ~/satan-corpus and `_templates/agents`: `devShells.x86_64-linux.default`
- ~/flakes: `homeConfigurations."david@Sleipnir".activationPackage`, with
  `just --evaluate local_override`. This covers the `eca` jail.
The NixOS system is left out: its `/etc/nix/registry.json` names the agents
source tree, so any edit under agents/, a README one included, changes it.

## Progress

- Step 1 done. The handover was untracked (`*.local.md`) and was deleted
  without a commit; it is gone. The README loses its `commonPkgs`,
  `blockGitPush` and "Full example" entries. Gate green, consumers unchanged.
