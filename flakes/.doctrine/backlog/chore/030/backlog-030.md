# CHR-030: Migrate the remaining project flakes to dev-envs

Twelve project flakes still build their own jails and devshell. Until they move, their
`jcl` and friends don't start in a session (zmux IMP-007: `shorthand` in
`dev-envs/flake.nix` goes through `zmx-new`, so only `use_dev_envs` projects get it).

Done: retrograde (`70b44f2`, the pilot).

## Decided (operator, 2026-11-06)

- **Doctrine: `dev-tools` carries none; a room gets it from `capsule-tools`** (DEC-128).
  CHR-031 audits the projects and their fleet targets.
- No `d` or `sdr` aliases. Don't carry them over.

## Doctrine in `dev-tools` shadows the host install

Measured in a jail built by dev-envs with malebolge as the project:

```
/nix/store/...-malebolge-dev-tools/bin/doctrine     wins, 0.46.10
/home/david/.local/share/doctrine/bin/doctrine      host, 0.48.1
```

`extraPkgs` lands ahead of `hostDoctrineOptions`' `add-path` (`agents/jailed-agents.nix`).
DEC-128 removes the cause: Doctrine moved to `capsule-tools`, in DEC-112's order (CHR-031,
done). No jail-library change is needed.

## Steps per project

Read the whole flake first. A survey by grep undercounted malebolge.

1. Export `packages.<system>.dev-tools`: the gate's tools, no agents.
2. Move jail env to `dev-tools.passthru.devEnv`, which takes only `env`, `hostEnv` and
   `outerGitDir`. `set-env` goes to `env`, `try-fwd-env` to `hostEnv`. `checkDevEnv`
   refuses a name the host layers own.
3. Move `workspaceDeps` to `JAIL_WORKSPACE_DEPS` in `.envrc`, as `~/dev/satan/.envrc` does.
4. `.envrc`: `source_env_if_exists ~/flakes/envrc/dev-envs.sh`, then
   `use_dev_envs || use flake .`. Keep any other lines, such as malebolge's `DOCTRINE_BIN`.
5. Delete the jails, the shell's agent commands, and the `agents` and `quotient` inputs.
   `nix flake lock`. On the Mac the project's own shell carries no agents.
6. If the project has `.quotient`: `~/flakes/bin/dev-envs-forms`, then `quotient allow`
   (the operator's act). See IMP-064.
7. Verify with `nix develop` as `use_dev_envs` runs it: tools resolve, `jcl --version`
   prints, and the gate gives the same result as the old shell. Build the old shell from
   `git+file:$PWD?rev=<HEAD>`, which leaves the tree alone. Run the gate in `jsh` too.
   The operator then runs `direnv allow`.

Consequences seen in retrograde:

- `devEnv.env` also reaches the host shell, where the old flake set it in jails alone.
- `.#jailed-*` outputs go. Check nothing references them; the fleet flake lists several
  of these projects.
- `devEnv` can't bind a path. `try-readwrite "/run/user/1000/docker.sock"` and
  `exposePostgres` have no equivalent. retrograde used neither, so they went.
- retrograde's `just check` fails on 2 vitest cases in `srd_threshold_parity`, on the old
  shell too. Not caused by the migration.

## Projects

The five with `dev-tools` evaluate under dev-envs. That proves evaluation only.

| project | `dev-tools` | `.envrc` | known work |
|---|---|---|---|
| malebolge | yes | agents_dev | forms; bridge; workspace deps |
| oubliette | yes | use flake | |
| panopticon | yes | agents_dev | `NIRI_SOCKET`; own forms |
| goad | yes | agents_dev | GUI env, `shellHook`; `XDG_RUNTIME_DIR` and `CLAUDE_CODE_SHELL` may clash with host names |
| bough | no | agents_dev | docker lines; workspace deps |
| vk | no | agents_dev | docker lines; workspace deps |
| forgettable | no | agents_dev | docker lines; workspace deps |
| spec-driver | no | agents_dev | workspace deps; own `commands` to read |
| deck_of_dwarf | no | use flake | nix-ld env, `shellHook`, own forms |
| emacs-config | yes | agents_dev | path binds (emacs server, podman socket, sound); `gitIdentity`; own forms; workspace deps; `d`, `sdr` |
| notes | yes | agents_dev | `jpi` passes `-e .pi/extensions/satan.ts --skill <goad-backend>`; workspace deps |
| satan-corpus | no | agents_dev | emacs server bind; `jailed-pi-emacs`; `jpi` passes the same extension; workspace deps |
| resume | yes | use flake | `.envrc` only: its flake builds no jails |

dev-envs has nowhere to put a `shellHook`, so goad and deck_of_dwarf may stay on their
own flakes. emacs-config and satan-corpus may too: `devEnv` can't bind a path, and their jails do.
notes and satan-corpus bake flags into `jpi`. dev-envs fixes each shorthand's flags
(`shorthands`, `dev-envs/flake.nix`) and a project cannot add its own, though a caller's
arguments pass through. Read the hooks before deciding. Staying is an acceptable outcome.

### malebolge

- **Forms:** they add `emacs-nox` (`just ert`) and `util-linux` (`flock` in
  `test/room-behind.test.ts`). dev-envs builds forms from `dev-tools`, which is also the
  room's tool set, so the room would grow by an Emacs. Undecided: accept that, or give
  dev-envs a way to add form-only tools.
- **Bridge:** malebolge's CHR-009 says `jailed-pi-bridge` and `bridgeOptions` are obsolete,
  since the agents lib gives every pi jail the bridge. Check `jailed-pi` carries all four
  DEC-074 clauses, the read-only project mount included, then close it with this.

### bough, vk, forgettable

Same template as retrograde, plus the docker socket lines. Check each for real Docker
use. If one needs it, dev-envs needs a way to bind a path.

## Joined, flake not cleaned

These `.envrc`s already run `use_dev_envs`, so only step 5 and any step 6 remain. Their
flakes keep what the old shell needed, now reached only by the `use flake .` fallback.

| project | still in the flake |
|---|---|
| www | jails, shell's agent commands, `agents` |
| smut | jails, forms, shell's agent commands, `agents`, `quotient` |
| satan-attrd | jails, forms, shell's agent commands, `agents`, `quotient` |
| org-incremental-writing | jails, forms, shell's agent commands, `agents`, `quotient` |
| sediment | jails, forms, shell's agent commands, `agents`, `quotient` |
| screwtape | forms only, with their own Doctrine; `agents`, `quotient` |

Before deleting, check that each jail's env reached `devEnv` and its `workspaceDeps`
reached `.envrc`. Not checked yet. org-incremental-writing sets `ORG_IW_DENOTE_DIR` and
`DOCTRINE_RESERVATION_FALLBACK`; smut, org-incremental-writing and sediment have
`workspaceDepsRw`. satan is not on this list: its remaining jails are product harnesses.

## Order

1. Doctrine to `capsule-tools` where a project has it in `dev-tools`: done (CHR-031).
2. oubliette, panopticon, malebolge.
3. bough, vk, forgettable, spec-driver.
4. goad, deck_of_dwarf, emacs-config, notes, satan-corpus, or decide they stay.
5. resume, and the flakes under "Joined, flake not cleaned", at any point.
