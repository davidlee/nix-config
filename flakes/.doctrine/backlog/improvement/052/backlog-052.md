# IMP-052: One confinement posture shared by agent jails and quotient forms

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

## Context

Found in CHR-023 (W5) while checking whether doctrine's interim quotient form
can move onto `quotientFormFamily` (IMP-046). It cannot without either a
confinement regression or a second copy of the posture. Two jail builders,
neither taking the other's posture:

```
 agents lib  makeJailedAgent                  quotient  mkFormFamily
   baseJailOptions, profile (network/home)      empty-env bwrap (no /proc/1/environ leak)
   hostDoctrine bind (--args 23)                LANG/TERM, persistHome, network
   hostGitExcludes, envOptions                  packages, options(c), env
   ssh-push block, sandboxed git identity       secretEnv over an fd
   guardedGit, commonPkgs                       state-dir mask, protect, piFiles
   gateway (fd 22), workspace binds             root + session bind, chdir
   extraPkgs, extraOptions                      baseline (for quotient's check)
                                                     ▲
                                  quotientFormFamily │ adds gateway wiring only
```

- doctrine's interim form (`~/dev/doctrine/flake.nix`, `quotientForms`) is a
  `makeJailedPi` jail plus raw root/session binds: it keeps the lib posture but
  loses quotient's guarantees (empty-env bwrap, state-dir mask, baseline).
- `quotientFormFamily` keeps quotient's guarantees but loses the lib posture:
  ssh-push block, git identity sandbox, guarded git, host doctrine (doctrine's
  delegates need the CLI), commonPkgs, git excludes.
- The project half doesn't transfer either: a project's `jailEnvOptions` is a
  list over `jailLib.combinators`; `mkFormFamily`'s `options` is a function
  over its own combinator set `c`. doctrine would write `DOCTRINE_BIN`,
  `LD_LIBRARY_PATH`, `CARGO_BUILD_RUSTFLAGS` twice.

## Proposal (inference, unverified)

Posture as a function over combinators, written once:
- the lib exports `posture { profile, hostDoctrine, … } : c -> [option]`;
  `makeJailedAgent` applies it with `jail.combinators`, `quotientFormFamily`
  passes it into `mkFormFamily`'s `options`;
- a project writes `projectOptions = c: [ … ]` once and feeds both.

## Settled (2026-10-27)

Process: no slice unless it turns hairy (several phases, several adversarial
review rounds); this card carries the decisions and the plan.

**quotient's check: a wiring gap, not a design conflict.** Tested with
`quotient.lib.checkFormFamily` over scratch families (quotient a902e77,
jail.nix 404e7da):

| option shape | check |
|---|---|
| none (control) | pass |
| `unsafe-add-raw-args "--args 23 23< <(…)"` (today's `hostDoctrineOptions`) | refused: "(c)/(e) the bwrap line is not plain words" |
| `add-runtime "exec {fd}< <(…); RUNTIME_ARGS+=(--args \"$fd\")"` | pass; listed as a residue (runtime binds the check cannot see) |

The check refuses a process substitution or `$(…)` on the bwrap line;
`add-runtime` is quotient's sanctioned, unchecked channel (`docs/nix-forms.md`
§ 6). Lib posture parts in the refused shape:

- `hostDoctrineOptions` (`jailed-agents.nix:345`): `--args 23 23< <(…)`
- `hostGitExcludesOptions` (`jailed-agents.nix:154`): `"$(…)"` bind source
  (not yet tested in the `add-runtime` shape)

Not posture, so not a problem:

- gateway key (fd 22) and provider keys (fd 21, `setenvsByArgsFd`): a form
  takes them through quotient's own `secretEnv` descriptor.
  `quotientFormFamily` already does so for the gateway. The user observes forms
  reach the gateway without it being passed in, so quotient's system config
  supplies it.
- launch-dir mount (`jailed-agents.nix:234`): launcher; a form has root and
  session binds instead.

**Ownership:** the agents lib (here). quotient's `options` contract needs no
change.

## Split (draft, mostly agreed)

```
posture (shared)                     launcher (makeJailedAgent only)
  baseJailOptions                      workspaceBinds, launch-dir mount
  hostDoctrine            (rewrite)    profile home / network  (forms: persistHome, network)
  hostGitExcludes         (rewrite)    subagents, JAILED_AGENT_DEPTH
  envOptions                           apiKeyPassThrough, gateway (forms: secretEnv)
  ssh-push block                       extraOptions
  sandboxed git identity
  guardedGit, commonPkgs
```

## Decisions (agreed 2026-10-27)

- D1 `exposePostgres`: project option, not posture. It widens the jail, and a
  form must declare the read-write bind in `exposure` anyway.
- D2 `extraPkgs`: project option (`c.add-pkg-deps`). Posture keeps
  `commonPkgs` and guarded git.
- D3 `sandboxGitIdentity`: a posture parameter. `makeJailedAgent` passes the
  profile's value; `quotientFormFamily` defaults it to `true` (forms are
  delegates).
- D4 `envOptions`: posture, except the terminal settings. quotient sets
  `TERM=dumb` before the caller's `options`, so the posture's `TERM` would
  override it in a headless form. `TERM`, `COLORTERM`, `TERMINFO_DIRS` moved
  to `terminalOptions` (launcher); `CLAUDE_CODE_SHELL`, `UV_CACHE_DIR` stay.
- D5 combinator sets: `projectOptions = c: [ … ]` needs `jail.combinators` and
  `mkFormFamily`'s `c` from the same jail.nix. Document "go through
  `quotientFormFamily`" (it passes this lib's pin); no guard.

Confirmed in step 1: `add-runtime` args land after every static mount;
harmless. A launched jail reads the host excludes and runs the host doctrine.

## Plan (approved 2026-10-27; done, step 4 dropped)

Each step TDD red/green/refactor; `just test` green at the end of each.

1. Rewrite `hostDoctrineOptions` and `hostGitExcludesOptions` as `add-runtime`
   code (`exec {fd}< <(…); RUNTIME_ARGS+=(…)`). Existing jail tests keep
   passing; update any that assert today's text.
2. Extract `posture { hostDoctrine ? true, sandboxGitIdentity, blockSshGitPush
   ? true, guardGit ? true } : c -> [option]` over a combinator set;
   `makeJailedAgent` applies it to `jail.combinators`. No behaviour change.
3. `quotientFormFamily` prepends the posture to the caller's `options`; the
   caller's `options` stays `c: [ … ]` (the project half).
4. Test: `quotient.lib.checkFormFamily` passes over a family built with the
   posture. Add a target to `just test` if it runs offline.
5. README (agents § quotient forms) and this card: the posture, the project
   half, D5. Then CHR-023 can move doctrine's interim form (doctrine CHR-183)
   and satan's hand-rolled family onto it.

## Progress

1. Done. `hostGitExcludesOptions` is `add-runtime` (`RUNTIME_ARGS+=(…)`);
   `hostDoctrineOptions` reads the closure binds with `mapfile` into
   `RUNTIME_ARGS`: store paths, so argv is fine, and descriptor 23 is gone.
   Tests assert the runtime shape and that runtime args follow the home bind.
2. Done. `posture { sandboxGitIdentity; hostDoctrine ? true; blockSshGitPush
   ? true; guardGit ? true; } c` runs first in `makeJailedAgent`; posture
   parts are `c:` functions; exported as `posture`. Launcher before/after:
   same words, same PATH; only `/run/doctrine-bin` moved earlier (overlaps
   nothing). Tests build a jail from the posture over plain jail.nix
   combinators, each flag removing its part.
3. Done. `quotientFormFamily { postureFlags ? {}; options ? (_: []); … }`:
   `options = c: posture ({sandboxGitIdentity = true;} // postureFlags) c ++
   options c`. Test: a probe jail from the form's options has the posture and
   the caller's option; a flag reaches it.
4. Open. The root flake has no `quotient` input (only screwtape, as
   `git+file`), contrary to the preflight assumption. Ad hoc in scratch:
   `checkFormFamily` passes over `quotientFormFamily` with the real posture;
   the built form keeps `TERM=dumb`, and `quotient-read <session> --version`
   launches (pi 1.4.0). Dropped (user, 2026-10-27): no quotient pin in this
   repo. Coverage comes from CHR-023, whose forms run the check.
5. Done: `agents/README.md` (exports, Sandbox defaults marks *posture*,
   § quotient forms: posture, `postureFlags`, project half, PATH, plain-words
   rule).

`just gate` green (tests + treefmt) after step 5.

Downstream: screwtape's `quotientFormFamily` call gains the posture on its
next agents re-lock. malebolge's flake carries a note asking for
`hostDoctrineOptions` to bind at the host path rather than
`/run/doctrine-bin`; out of scope here.

Blocks CHR-023's form step: doctrine's interim form (doctrine CHR-183) and
satan's hand-rolled `quotientFormFamily`.
