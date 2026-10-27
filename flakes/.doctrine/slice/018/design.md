<!-- doctrine:section sec-1 -->
## Summary

Workspace deps bind read-only by default; read-write is an explicit opt-in
(DEC-081). The launch dir is bound after the deps so the project being worked
on is always visible and rw (DEC-082). Implements IMP-044 (programme W1).

```
workspaceDeps   ++ $JAIL_WORKSPACE_DEPS     ─> --ro-bind <src> /workspace/<basename>
workspaceDepsRw ++ $JAIL_WORKSPACE_DEPS_RW  ─> --bind    <src> /workspace/<basename>
$PWD (launch dir, bound last)               ─> --bind    $PWD  /workspace/$(basename $PWD)
```
<!-- doctrine:section sec-2 -->
## API and semantics

`makeJailedAgent` (and every maker that forwards to it) gains one argument:

| argument | default | meaning |
|---|---|---|
| `workspaceDeps` | `[]` | absolute paths bound **read-only** at `/workspace/<basename>` (was rw) |
| `workspaceDepsRw` | `[]` | absolute paths bound **read-write** at `/workspace/<basename>` |
| `workspaceDepsFromEnv` | `true` | merge `JAIL_WORKSPACE_DEPS` (ro) and `JAIL_WORKSPACE_DEPS_RW` (rw); `false` ignores both |

- Both env vars: newline- or colon-separated absolute paths, read only under
  impure eval (pure eval: empty, no-op), as today.
- One pipeline for both lists: each mode's static and env entries are merged
  and deduplicated, every entry normalised (trailing slashes stripped) and
  tagged with its mode, then the two tagged lists concatenate into one set of
  bind specs `{ source, destination, mode }`.
- Guards run over the union: a relative path is refused; two specs with the
  same destination are refused, whatever their modes. So a path in both
  lists, or two paths sharing a basename across lists, fails evaluation with
  the existing message.
- Bind flag by mode: `--ro-bind` or `--bind`; the existing escaping
  (`escapeWorkspaceBindArgs`, ShellCheck SC2016) applies to both.
- Breaking: an existing consumer whose agents write a dep must move it to
  `workspaceDepsRw` / `JAIL_WORKSPACE_DEPS_RW`.
<!-- doctrine:section sec-3 -->
## Bind order

Option order in `inner` becomes `baseJailOptions`, workspace binds, then
`launchDirOptions` (was launch dir before workspace binds,
`agents/jailed-agents.nix:620-623`). bwrap applies mount operations in argv
order, so the launch-dir bind is the one visible at
`/workspace/<project>` when a dep shares its basename (DEC-082). The clash
is a run-time fact (`$PWD`), so no eval-time guard is attempted; the shadowed
dep is simply not visible. `--chdir` stays inside `launchDirOptions`.

Destinations are flat siblings under `/workspace`, so ro and rw deps never
nest at the destination even when their sources do (research.md finding 1).
<!-- doctrine:section sec-4 -->
## Code impact

- `agents/jailed-agents.nix` — args (`workspaceDepsRw`), env parse
  generalised over a variable name, mode-tagged bind specs, flag by mode,
  option order. Header comment and arg comments updated.
- `agents/jailed-agents-test.nix` — quoting test expects `--ro-bind` for
  `workspaceDeps`; a twin for `workspaceDepsRw` expects `--bind`;
  cross-list duplicate refused; launch-dir bind follows workspace binds in the
  launcher.
- `agents/jailed-agents-env-test.nix` — asserts mode per env var; envOff drops
  both.
- `justfile` (`test`) — the impure check also sets
  `JAIL_WORKSPACE_DEPS_RW=/nonexistent/env-rw-dep`.
- `agents/README.md` — workspace-deps prose (~L218-238) and option table
  (~L521-522): ro default, rw list, env var, bind order.
- `_templates/agents/flake.nix` — comment and example show both lists;
  jails `inherit` both.
- `~/.config/emacs/flake.nix` (outside this repo's tree; no selector) —
  `notes` and `.local/state/behaviour` move to `workspaceDepsRw`; the rest stay
  in `workspaceDeps`; jails `inherit` both.
<!-- doctrine:section sec-5 -->
## Verification

- `just test` green: pure `checks.jailed-agents` and impure
  `impureChecks.jailed-agents-env` cover ro default, rw opt-in, both env vars,
  `workspaceDepsFromEnv = false`, relative and cross-list duplicate refusals,
  and launch-dir-last ordering (VT).
- `just gate` (alejandra, statix, deadnix) clean (VT).
- A built launcher from the Emacs devshell flake inspected: `--ro-bind` for
  its `workspaceDeps`, `--bind` for its `workspaceDepsRw`, launch dir last
  (VA, plan PHASE-02 VA-1). The template, built with one entry in each list,
  shows the same at audit (RV-040 F-3).
- README option table matches the arguments (VA).
<!-- doctrine:section sec-6 -->
## Rollout

- Repos on the live-agents `.envrc` hack pick the flip up at the next direnv
  reload; locked consumers at their next agents bump.
- Out-of-repo rw lists are W5 (CHR-023): on landing, append to CHR-023 the
  dep lists of every consumer of the agents lib, with the note that writes
  now need the rw list. CHR-023 holds the full table (thirteen repos; the
  six first named here missed satan-corpus, bough, vk, forgettable,
  spec-driver, _SDLC and notes, RV-040 F-2). Anything else goes ro and is
  fixed forward (inq-2).
- satan is being reworked by another agent; it is told of the flip through
  CHR-023 rather than edited here.
