# SATAN — deployment on Sleipnir

Host-specific facts for the SATAN agent system: where each part lives on this
machine, how ~/flakes composes it, which units run it, and how paths map into
jails. The architecture (containers, transports, invariants) is **SPEC-002**
in `~/dev/satan` (`doctrine spec show SPEC-002`, diagrams in
`~/dev/satan/.doctrine/spec/tech/002/`). This note changes with the machine;
the spec changes with decisions.

Surveyed read-only 2026-09-25. Citations are `path:line`; re-check before
relying on a line number.

## Repos

| Part | Path | Flake input here | Deployed by |
|---|---|---|---|
| broker (elisp) + harness | `~/dev/satan` | `satan = github:davidlee/satan` (`path:` commented out, `flake.nix:81`) | elisp: `~/.emacs.d/apps/dl-satan.el` loads the **live tree**; harness: `home.packages` from the **pin** (`modules/home/linux/satan.nix:19-21`) |
| corpus | `~/satan` | — | own repo; `just commit` there |
| editor config | `~/.emacs.d` | — (the Emacs package comes from `github:davidlee/nix-config?dir=flakes/emacs`) | HM `services.emacs` (`modules/home/shared/emacs.nix:36-43`) |
| satan-attrd | `~/dev/satan-attrd` | `path:` (`flake.nix:93-98`) | `modules/home/linux/satan-attrd.nix` |
| satan-patcher (= `~/dev/sloptower` symlink) | `~/dev/satan-patcher` | `path:` (`flake.nix:88-91`) | `modules/home/linux/satan-patcher.nix` |
| panopticon | `~/dev/panopticon` | `path:` (`flake.nix:73-78`) | `modules/home/linux/behaviour.nix` |
| goad | `~/dev/goad` | `git+file:` (`flake.nix:100-102`), **no follows** | `modules/home/linux/goad.nix` |
| oubliette (= `~/dev/microvm-spike`) | `~/dev/oubliette` | `github:davidlee/oubliette` (`just` overrides to `git+file:`) | `modules/nixos/capsule.nix` (host module only; no capsules at boot) |
| jail library | `~/flakes/agents` | `agents = path:` (`flake.nix:20`) | consumed by every repo's flake |

All modules are imported from `hosts/Sleipnir/home.nix:7-11`. `just
update-local` refreshes satan, satan-attrd, panopticon and satan-patcher, but
**not goad**.

### Composition quirks (violate SPEC-002 NF-002 / NF-003)

- **Cycle.** satan's `agents` input is `github:davidlee/nix-config?dir=flakes/agents`,
  the repo this directory lives in (`~/.git`), while this flake takes satan as
  an input. `follows` hides it here; standalone satan builds use a different
  library revision.
- **Two revisions of satan.** The harness binary comes from the GitHub pin;
  systemd runs `~/dev/satan/satan/bin/*` and Emacs loads elisp from the live
  tree.
- **Jail library copies.** goad resolves its own `flakes/pub` pin (rev
  `6bf9955`); satan-attrd, goad and `~/notes` still name the deprecated `pub`
  alias (`pub/flake.nix:2`).
- `~/dev/sloptower/nix/module.nix` duplicates satan-patcher's module
  (`services.satan-patcher`); importing both would collide.

## Units (all `systemctl --user`)

| Unit | Runs | Schedule | Source |
|---|---|---|---|
| `satan-morning` | `~/dev/satan/satan/bin/satan-run morning` → `emacsclient --eval '(satan-run "morning")'` | 09:15 | `satan.nix:23-41` |
| `satan-motd` | `satan-run motd` | 08:15 | `satan.nix:43-58` |
| `satan-tick` | `satan-run-tick` → `(satan-tick)` | **once, 5 min after boot** (`OnUnitActiveSec` commented out; ISS-022) | `satan.nix:72-84` |
| `emacs` | `emacs --fg-daemon`, WorkingDirectory `~` | always | HM `services.emacs` |
| `satan-attrd` | `satan-attrd run`, `DATABASE_URL=postgres:///satan_memory?host=/run/postgresql` | always | `~/dev/satan-attrd/nix/module.nix:44-91` |
| `satan-patcher` | Go daemon, 30 s queue tick, `op read` in ExecStartPre; PATH = nix, git, coreutils | always | `~/dev/satan-patcher/nix/module.nix:119-151`, override `satan-patcher.nix:56-68` |
| `panopticon-sway` | `panopticon-desktop` (auto compositor) | graphical session | `behaviour.nix:22-35` |
| `panopticon-git` / `panopticon-segmentize` | pollers | every 5 / 10 min | `behaviour.nix:37-100` |
| `goad` | tray GUI; config `~/.config/goad/config.toml` (not nix-managed) | graphical session | `goad.nix` |
| `wpm-daemon`, `wpm-archive` | `~/.config/waybar/wpm-status.py` → `~/.local/state/satan/log/wpm` | always / 04:00 | `sway.nix:79-105` |

Stale comments in `satan.nix`: `Documentation=%h/.emacs.d/SATAN.local.md`
(file does not exist — point it here); `dl-satan-*` names and "default
400000" (real: `satan-budget-daily-tokens` = 2500000); "every 30 minutes".

## Storage

| Root | Path |
|---|---|
| notes (user's; SATAN read-only) | `~/notes` |
| corpus | `~/satan` |
| state | `~/.local/state/satan` (`runs/`, sensor JSON, `goad/queue.json`, `patch-agent/{logs,worktrees}`, `log/wpm/`) |
| perception | `~/.local/state/behaviour` (panopticon) |
| goad day records | `~/satan/goad/data/` (written by `~/satan/goad/backend.py`) |
| MCP socket | `/run/user/1000/satan/mcp/mcp.sock` |
| Emacs server socket | `/run/user/1000/emacs/server` |
| goad ingress | `/run/user/1000/goad.sock` |

**Postgres** (`modules/nixos/postgresql.nix`): PostgreSQL 18, socket
`/run/postgresql`, no TCP; role `david` superuser; `ensureDatabases = [david
corpus]`. **`satan_memory` is not declared** — created by hand. Migrations:
elisp `~/dev/satan/satan/memory/migrations/0001–0008` (`schema_migrations`);
`satan-attrd migrate` 0007–0012 (`_sqlx_migrations`); satan-patcher `just
migrate` applies 0006. Tests use Supabase on `127.0.0.1:54322`. Nothing
found using the `corpus` database.

**Secrets:** 1Password via `/run/wrappers/bin/op` (`modules/nixos/programs.nix:152-160`).
The broker resolves `op://` refs through `my/satan-credential`
(`~/.emacs.d/lisp/dl-secret.el:141`); jails use `op run --env-file` or FD 21.
The library ref map (`agents/jailed-agents.nix:36-43`) has no
`ANTHROPIC_API_KEY`.

## Jails

Library `agents/jailed-agents.nix` (bwrap via jail.nix). Every jail binds the
launcher's `$PWD` **rw** at `/workspace/$(basename $PWD)` and chdirs there
(`:115-116`); binds each `workspaceDeps` entry rw at `/workspace/<basename>`;
persists `$HOME` from `~/.local/share/jail.nix/home/<profile-home>` (`specDev`
→ `agent`, shared by the harness and every interactive dev jail).

### Host path → in-jail path

| Host path | prod harness `jailed-satan-gptel-harness` | satan dev jails (`~/dev/satan` flake) | corpus jails (`~/satan` flake) | patcher job (`jailed-pi`) |
|---|---|---|---|---|
| launcher cwd | `/workspace/<basename>` rw — Emacs cwd, probably `~` | `/workspace/satan` | `/workspace/satan` | `/workspace/<job-id>` (job clone) |
| `~/dev/satan` | `/workspace/satan` **rw** ("Migration !!") | cwd | `/workspace/satan-src` ro | — |
| `~/notes` | `/satan/notes` ro | `/workspace/notes` **rw** | `/workspace/notes` rw | `/workspace/notes` rw |
| `~/satan` | only `hippocampus/` → `/satan/hippocampus` | `/workspace/corpus` rw | cwd | `/workspace/corpus` rw |
| run dir | `/satan/run` | — | — | — |
| `~/.local/state/behaviour` | — | `/workspace/behaviour` rw | — | `/workspace/behaviour` rw |
| `~/flakes`, attrd, patcher, panopticon repos | — | `/workspace/<name>` rw | — | same as dev |
| MCP socket, Emacs server socket | — | same path, rw | MCP only | — |

Sources: `~/dev/satan/flake.nix:70-148, 213-289`; `~/satan/flake.nix:55-66`;
`~/dev/satan-patcher/internal/worktree/worktree.go:42-70`. Other repos' dev
jails differ again: satan-attrd adds `/run/postgresql` + the docker socket;
goad adds `~/.local/src/slint` → `/workspace/slint` ro; panopticon adds the
niri socket; `~/.emacs.d` and `~/notes` flakes add MCP only.

Inside a jail `~/flakes` has no git: its git dir is `~/.git`, which is not
mounted.

### Known gaps (SPEC-002 NF-004)

- MCP dev jails bind the Emacs server socket rw: arbitrary elisp from inside
  the jail.
- The broker never sets `default-directory` before spawning the harness, so
  the harness's `$PWD` bind is the Emacs daemon's cwd — probably all of `~`, rw.
  Unverified against a live run.
- `try-fwd-env` puts forwarded API keys on bwrap's argv; the harness gets them
  that way as well as via FD.
- `SATAN_MAX_BUDGET_TOKENS` is not forwarded, so the harness's hard budget
  backstop is disabled.
- satan-patcher: all 17 jobs failed (newest 2026-05-20); likely cause is
  `jailed-pi` missing from the unit PATH.
