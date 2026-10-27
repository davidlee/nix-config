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

## Settle first

- quotient's check: a quotient commit says it "refuses globs, nested quoting,
  climbs and fd binds". `hostDoctrineOptions` (`--args 23`) and the gateway
  (fd 22) may be refused inside a form. If so the conflict is between the two
  designs, not a wiring gap. Test before designing.
- Which of `makeJailedAgent`'s parts are posture and which are launcher
  (launch-dir mount, subagents, profile home vs `persistHome`, network flag).
- Ownership: the agents lib (here) and possibly quotient's `options` contract.

Blocks CHR-023's form step: doctrine's interim form (doctrine CHR-183) and
satan's hand-rolled `quotientFormFamily`.
