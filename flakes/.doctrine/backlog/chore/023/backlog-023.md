# CHR-023: W5 — Migrate /workspace repos to the canonical dev-flake pattern

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

Programme W5. Move each `/workspace` repo with an agents input onto the W4
(IMP-047) pattern: org-incremental-writing, retrograde, satan-attrd, www,
goad, malebolge, panopticon, oubliette, doctrine, screwtape, satan.
Mechanical; delegable per repo. Changes land in each repo, not here.

Per repo: `.envrc` helper, ro/rw deps (W1), form helper where it has a form
(W3), drop stale bits. Known stale: panopticon's devshell still runs
`op run -- jailed-pi` though its jail uses the gateway.

satan last: another agent is reworking its flake (2026-10-27).

After IMP-051: satan's `op-unjailed` check becomes a call to the lib's
scanner as part of its migration, and remaining `useOpEnv` consumers move to
the gateway (panopticon's `op run` is one).

## SL-018: workspace deps are read-only by default (2026-10-27)

`workspaceDeps` and `JAIL_WORKSPACE_DEPS` now bind `--ro-bind`; a dep the
agents write must move to `workspaceDepsRw` / `JAIL_WORKSPACE_DEPS_RW`
(DEC-081). A path in both lists fails evaluation. Repos on the live
`use flake_local agents` `.envrc` already see the change; locked ones at their
next agents bump. Each consumer's deps as of the flip, all now read-only:

| repo | static `workspaceDeps` | `.envrc` `JAIL_WORKSPACE_DEPS` |
|---|---|---|
| doctrine | — | spec-driver, forgettable, ~/.local/src/superpowers, flakes, oubliette |
| panopticon | — | satan, ~/.config/emacs, flakes |
| satan | flakes, notes, .local/state/behaviour, satan-attrd, satan-patcher, panopticon (fake-harness jail: none) | notes, ~/.config/emacs, flakes, panopticon, malebolge, quotient, oubliette |
| goad | — | `~/.local/src/slint` |
| org-incremental-writing | ~/.emacs.d, notes | — |
| satan-attrd | ~/.emacs.d | — |

Paths are `~/dev/<name>` or `~/<name>` unless shown. Likely rw: `notes` and
`.local/state/behaviour` (satan, org-incremental-writing), as the Emacs
devshell did (`~/.config/emacs` 94a1f9e). Anything else stays ro until a write
fails (fix forward).

Trap: a path moved to the static rw list must also leave the ro env var, or
the two lists share a destination and evaluation fails. satan lists `notes`
in both its static deps and its `.envrc`.

goad: the `~` in its `.envrc` is literal inside double quotes, so the path is
relative and the jail refuses evaluation. That predates SL-018; use
`$HOME/.local/src/slint`.

More consumers on the same flip, found at audit (RV-040 F-2), all on the live
`use flake_local agents` `.envrc` unless shown:

| repo | static `workspaceDeps` | `.envrc` `JAIL_WORKSPACE_DEPS` |
|---|---|---|
| satan-corpus | .emacs.d, notes, goad, oubliette, panopticon, satan-attrd, satan, satan-patcher | — |
| bough | .emacs.d | — |
| vk | .emacs.d | — |
| forgettable | .emacs.d | doctrine, ~/.local/src/superpowers, flakes |
| spec-driver | autobahn | doctrine |
| _SDLC | `/home/you/dev/some-lib` (template placeholder) | — |
| notes (locked, flips at its next agents bump) | ~/.config/emacs | — |

Likely rw: satan-corpus's `notes` and `satan` (SATAN.md § Jails: corpus jails
write both).

## Write-fix done early (2026-10-27)

The first part of W5, done ahead of IMP-047 and IMP-051 so that jails which
write their deps work again. Uncommitted in each repo:

| repo | moved to `workspaceDepsRw` | still ro |
|---|---|---|
| satan-corpus | none: someone else's edit at 11:53 put `~/notes` and `~/dev/satan` back to ro (the file was also reformatted) | all |
| org-incremental-writing | `~/notes` | .emacs.d |
| satan | `.local/state/behaviour` (handed to satan-d4, which owns the flake rework) | `notes`: the user ruled satan does not write it, so the `.envrc` entry stays |

Verified against the live agents lib (`--override-input agents
path:~/flakes/agents`). Each built jail's wrapper has `--bind` for the rw deps
and `--ro-bind` for the rest.

Found on the way: satan-corpus's `jailed-pi-emacs` builds as
`jailed-jailed-pi-emacs`. It passes `name = "jailed-pi-emacs"`, and the maker
adds the prefix again. Fix it with the W5 migration.

The rest of CHR-023 still waits for IMP-047 and IMP-051.

satan-corpus, later the same day: its rw move was reverted by someone else's
edit, deliberately as far as can be told (my comment and an empty
`workspaceDepsRw` were kept). Its jail rename (`jailed-pi-emacs` →
`pi-emacs`, IMP-045 step 5) is done, uncommitted there.
