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
| broker (elisp) + harness | `~/dev/satan` | `satan = github:davidlee/satan` (`path:` commented out, `flake.nix:81`) | elisp: `~/.config/emacs/apps/dl-satan.el` loads the **live tree**; harness: `home.packages` from the **pin** (`features/satan/harness.nix`) |
| corpus | `~/satan-corpus` | — | own repo; `just commit` there |
| editor config | `~/.config/emacs` | — (the Emacs package comes from `github:davidlee/nix-config?dir=flakes/emacs`) | HM `services.emacs` (`features/editor/emacs.nix`) |
| satan-attrd | `~/dev/satan-attrd` | `path:` (`flake.nix:93-98`) | `features/satan/attrd.nix` |
| panopticon | `~/dev/panopticon` | `path:` (`flake.nix:73-78`) | `features/attention/behaviour.nix` |
| malebolge | `~/dev/malebolge` | `malebolge = github:davidlee/Malebolge` (`just` overrides to `git+file:`) | runner: `features/satan/runner.nix` from the **pin**; the interactive daemon runs the **live tree** (`just daemon`, not a unit) |
| goad | `~/dev/goad` | `git+file:` (`flake.nix:100-102`), **no follows** | `features/attention.nix` (`attention.goad`) |
| oubliette (= `~/dev/microvm-spike`) | `~/dev/oubliette` | `github:davidlee/oubliette` (`just` overrides to `git+file:`) | `features/virt/capsule.nix` (host module only; no capsules at boot) |
| jail library | `~/flakes/agents` | `agents = path:` (`flake.nix:20`) | consumed by every repo's flake |

All modules are imported from `hosts/Sleipnir/home.nix:7-11`. `just
update-local` re-locks satan, agents, emacs and every `bin/dev-checkouts`
input (fleet, goad, malebolge, panopticon, satan-attrd) from its remote:
push first.

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

## Units (all `systemctl --user`)

| Unit | Runs | Schedule | Source |
|---|---|---|---|
| `satan-morning` | `~/dev/satan/satan/bin/satan-run morning` → `emacsclient --eval '(satan-run "morning")'` | 09:15 | `satan.nix:23-41` |
| `satan-motd` | `satan-run motd` | 08:15 | `satan.nix:43-58` |
| `satan-tick` | `satan-run-tick` → `(satan-tick)` | **once, 5 min after boot** (`OnUnitActiveSec` commented out; ISS-022) | `satan.nix:72-84` |
| `emacs` | `emacs --fg-daemon`, WorkingDirectory `~` | always | HM `services.emacs` |
| `satan-attrd` | `satan-attrd run`, `DATABASE_URL=postgres:///satan_memory?host=/run/postgresql` | always | `~/dev/satan-attrd/nix/module.nix:44-91` |
| `satan-runner` | malebolge's patch-job runner: `bin/satan-runner` of the **pin** `inputs.malebolge.packages.<system>.runner` (`nodejs_24` on its `src/runner-main.ts`, production deps; CHR-017); as `david`, the oubliette module owner (CON-003); gateway key by `LoadCredential=`; PATH = `/run/current-system/sw/bin` (capsule), git, openssh, socat, coreutils | always (`WantedBy=default.target`); config ships `enabled = false` (parked) until enabled, see [satan-runner](#satan-runner) | `features/satan/runner.nix` |
| `panopticon-desktop` | `panopticon-desktop` (auto compositor) | graphical session | `behaviour.nix:22-35` |
| `panopticon-git` / `panopticon-segmentize` | pollers | every 5 / 10 min | `behaviour.nix:37-100` |
| `goad` | tray GUI; config `~/.config/goad/config.toml` (not nix-managed) | graphical session | `goad.nix` |
| `wpm-daemon`, `wpm-archive` | `~/.config/waybar/wpm-status.py` → `~/.local/state/satan/log/wpm` | always / 04:00 | `features/desktop/sway.nix:106-150` |

Stale comments in `satan.nix`: `Documentation=%h/.emacs.d/SATAN.local.md`
(file does not exist — point it here); `dl-satan-*` names and "default
400000" (real: `satan-budget-daily-tokens` = 2500000); "every 30 minutes".

## Storage

| Root | Path |
|---|---|
| notes (user's; SATAN read-only) | `~/notes` |
| corpus | `~/satan-corpus` |
| state | `~/.local/state/satan` (`runs/`, sensor JSON, `goad/queue.json`, `patch-agent/{logs,worktrees}`, `log/wpm/`) |
| perception | `~/.local/state/behaviour` (panopticon) |
| goad day records | `~/satan-corpus/goad/data/` (written by `~/satan-corpus/goad/backend.py`) |
| MCP socket | `/run/user/1000/satan/mcp/mcp.sock` |
| Emacs server socket | `/run/user/1000/emacs/server` |
| goad ingress | `/run/user/1000/goad.sock` |
| runner store | `~/.local/state/satan/runner/runner.sqlite` (0700 dir, unit `StateDirectory=`): jobs, `job_events`, pi-durable |
| runner control socket | `/run/user/1000/satan-runner/control.sock` (dir 0700 `RuntimeDirectory=`, socket 0600) |
| runner config | `~/.config/satan-runner/{config.toml,ssh_config}` (HM-rendered from `features/satan/runner.nix`) |
| runner model catalog | `/nix/store/…-satan-runner-gateway.json`, the jails' own render (`agents/pi-gateway.nix` over `agents/gateway.nix` `models`) |
| daemon model catalog | `~/.config/malebolge/gateway-models.json`: HM symlink to the same store file as the runner's catalog (`features/satan/runner.nix`); read by the interactive daemon, which is not a unit (started by `just hello-durable` / `just daemon`) |
| room `known_hosts` | `/var/lib/capsule/room/assistant/known_hosts`: oubliette's; the runner only reads it |

**Postgres** (`features/services.nix`, `services.postgresql`): PostgreSQL 18, socket
`/run/postgresql`, no TCP; role `david` superuser; `ensureDatabases = [david
corpus]`. **`satan_memory` is not declared** — created by hand. Migrations:
elisp `~/dev/satan/satan/memory/migrations/0001–0009` (`schema_migrations`);
`satan-attrd migrate` 0007–0012 (`_sqlx_migrations`); the Go satan-patcher
migration 0006 is retired (SL-023 PHASE-14; 0009 drops `patch_jobs`). Tests use Supabase on `127.0.0.1:54322`. Nothing
found using the `corpus` database.

**Secrets:** SATAN holds no provider key (SL-022). Model traffic goes through
the LLM gateway; each jail's launcher reads a gateway client key from
`~/.config/llm-gateway/keys/<name>` and passes it in as `LLM_GATEWAY_KEY` over
`--args FD` (`agents/jailed-agents.nix:315-411`), never on argv. The harness
uses `keys/satan` (`deepseek-flash` only, $20 lifetime); the dev jails
(jailed-pi, -pi-research, -shell, -claude) use `keys/pi`. A missing key file
makes the launcher refuse. Issue a key with
`llm-gateway issue <name> --models <m> --budget <usd> --out ~/.config/llm-gateway/keys/<name>`;
`llm-gateway list` shows spend. The broker's `op://` path
(`my/satan-credential`, `~/.config/emacs/lisp/dl-secret.el:141`) is no longer
used by the harness; SL-022's broker phases remove it.

The runner uses `keys/satan-runner` (issued 2026-10-19), delivered by the
unit's `LoadCredential=satan-runner:~/.config/llm-gateway/keys/satan-runner`
(absolute in the unit) into `$CREDENTIALS_DIRECTORY`
(`/run/user/1000/credentials/satan-runner.service/`, 0400): on no argv and in
no environment. Its room identity is `~/.ssh/malebolge.key` (`[door]
identity`); its public half and `david@Sleipnir` are both in `/srv/fleet`
`rooms.assistant.users.agent.keys` (CON-004).

The interactive daemon (`~/dev/malebolge` `src/daemon-main.ts`) uses
`keys/malebolge`, which it reads from the file itself at start (default
`~/.config/llm-gateway/keys/malebolge`, override `MALEBOLGE_GATEWAY_KEY_FILE`;
the catalog path is `MALEBOLGE_GATEWAY_CATALOG`): on no argv, in no
environment. `jailed-malebolge` (`~/dev/satan/flake.nix`, satan CHR-018) binds
both read-only and sets both overrides; no provider key, no `op run`. The
satan flake check `malebolge-jail-profile` asserts it.

## Jails

Library `agents/jailed-agents.nix` (bwrap via jail.nix). Every jail binds the
launcher's `$PWD` **rw** at `/workspace/$(basename $PWD)` and chdirs there
(`:115-116`); binds each `workspaceDeps` entry rw at `/workspace/<basename>`;
persists `$HOME` from `~/.local/share/jail.nix/home/<profile-home>` (`specDev`
→ `agent`, shared by the harness and every interactive dev jail).

### Host path → in-jail path

| Host path | prod harness `jailed-satan-gptel-harness` | satan dev jails (`~/dev/satan` flake) | corpus jails (`~/satan-corpus` flake) |
|---|---|---|---|
| launcher cwd | `/workspace/<run-id>` rw — the run dir (broker sets it, ISS-037) | `/workspace/satan` | `/workspace/satan-corpus` |
| `~/dev/satan` | `/workspace/satan` **rw** ("Migration !!") | cwd | `/workspace/satan` rw (CHR-010: `workspaceDeps` basename mount, alongside the legacy `satan-src` ro-bind) |
| `~/notes` | `/satan/notes` ro | `/workspace/notes` **rw** | `/workspace/notes` rw |
| `~/satan-corpus` | only `hippocampus/` → `/satan/hippocampus` | `/workspace/satan-corpus` rw | cwd (`/workspace/satan-corpus`) |
| run dir | `/satan/run` | — | — |
| `~/.local/state/behaviour` | — | `/workspace/behaviour` rw | — |
| `~/flakes`, attrd, panopticon repos | — | `/workspace/<name>` rw | — |
| MCP socket, Emacs server socket | — | same path, rw | MCP only | — |

Sources: `~/dev/satan/flake.nix:70-148, 213-289`; `~/satan-corpus/flake.nix:55-66`.
Other repos' dev
jails differ again: satan-attrd adds `/run/postgresql` + the docker socket;
goad adds `~/.local/src/slint` → `/workspace/slint` ro; panopticon adds the
niri socket; `~/.config/emacs` and `~/notes` flakes add MCP only.

The runner's socket dir `/run/user/1000/satan-runner/` and the credentials dir
`/run/user/1000/credentials/` are bound into no jail (I4). Asserted by
`agents/jailed-agents-test.nix` (no launcher names `satan-runner`; none binds
the whole `/run/user/1000`) and `~/dev/satan` `checks.runner-socket-unjailed`
(`just check-jails`, every `jailPkgs` launcher). No test names `credentials`
itself: it is covered only by the whole-dir refute.

Inside a jail `~/flakes` has no git: its git dir is `~/.git`, which is not
mounted.

### Known gaps (SPEC-002 NF-004)

- MCP dev jails bind the Emacs server socket rw: arbitrary elisp from inside
  the jail.

## satan-runner

Malebolge's patch-job runner (SL-023 design §5.2-§5.3). One user unit, one
config file, one SQLite store; jobs run in the oubliette room `assistant`
(`/srv/fleet/flake.nix` `rooms.assistant`), reached through its door socket
`/run/capsule-room/assistant/ssh.sock`. The room and repo values in
`features/satan/runner.nix` are literals copied from the fleet (it exposes no
room data to home-manager); change them with the fleet.

The unit runs a store build, `inputs.malebolge.packages.<system>.runner`
(malebolge `flake.nix`; its check `runner-starts` proves the build loads),
never the working tree: an edit to `~/dev/malebolge` reaches the runner only
at the next `just home-switch`. That switch builds from the checkout when one
is present (`bin/dev-checkouts`; `git+file:`, so tracked files, dirty edits
included), else from the lock. Deploy a change: commit, push,
`just update-local`, `just home-switch`, `systemctl --user restart
satan-runner`.

### Switches

- **Runner kill switch:** `enabled` in the config (authority ledger row 6,
  owned by the runner). `false` parks it: it starts and serves the socket,
  refuses `submit` (`runner_disabled`) and schedules nothing. To enable, change the
  one line in `features/satan/runner.nix`

      enabled = false;   →   enabled = true;

  then `just home-switch`, then `systemctl --user restart satan-runner` (the
  config is read once at start). Disable the same way, back to `false`.
- **Unit:** `feature.satan.runner.enable` (`features/profiles/personal-linux.nix`,
  default on); `systemctl --user stop|start satan-runner` for a while.
- The prompt file `~/satan-corpus/prompts/patch-agent.md` must exist before
  any start, parked or not: start checks it before `enabled`, and a refused
  start (exit 1) retries 5 times in 300 s, then stops.
- Watch: `journalctl --user -u satan-runner -f` (start logs `store …` and
  `control …`; a refusal logs `refusing to start: …`). Socket:
  `stat -c '%a %U %n' /run/user/1000/satan-runner /run/user/1000/satan-runner/control.sock`
  → `700 david`, `600 david`.
- One consumer per repo (I1): satan-patcher removed (SL-023 PHASE-14); the
  runner is the only consumer. Stop the runner before any scratch instance.

### Modes and their scope (SL-025)

Every submit names a mode; Emacs stamps SATAN's acting run mode
(`patch_job_create` has no `mode` argument, DEC-068). Each `[mode.<m>]`
requires `repos` and `allowed_paths`, a list or `"*"`; the runner refuses a
submit outside them `invalid_request`, naming what the mode allows (DEC-069).
Scope is checked at submit only: narrowing it never touches an admitted job.

| mode | `repos` | `allowed_paths` |
|---|---|---|
| `self-edit-mech` | `satan` | `satan/` |
| `self-edit-mind` | `satan-corpus` | `prompts/`, `system/`, `tools/` |
| `tick-agent` | every repo but `satan`, `satan-corpus` (computed at eval) | `"*"` |
| `interactive` | `"*"` | `"*"` — the human's lane and the smoke's (RSK-019) |

No mode sets a model or ceiling: all use `defaults` and `maxima`. The repos
are the 15 room targets (`roomRepo` in `runner.nix`); a new room target needs
a line there too. New clones arrive empty (`room-seed` `git init`); each job
`capsule push`es its base branch to `refs/host/<branch>` (`/srv/fleet/PROVISION.md`).

### Room values (EX-5)

For a room kind door, exactly: `known_hosts =
/var/lib/capsule/room/<room>/known_hosts` and `host_key_alias = room-<room>`;
the unit runs as the uid owning that 0700 directory (`david`). Each repo:
`guest_path = /work/<target>`, `quarantine =
/var/lib/capsule/collect/<room>/<target>.git` (created by oubliette's first
collect; never by hand).

### Host keys

No seeding. Oubliette's `push` learns the room's key into `known_hosts`
(accept-new, oubliette DEC-047); the runner only reads it. A changed key fails
the job `failed`, reason `host_key`, from `preparing` or `running`; never a
pause. If the room was rebuilt on purpose, re-learning the key is oubliette's
remedy, not the runner's.

### `dirty_clone` remedy

A job failing `dirty_clone` (paths audited in its `transition` event) means the
room's clone of that repo holds residue; every later job on the repo fails the
same way until it is cleaned. The runner never cleans outside its post-collect
step. Inspect, then clean by hand, for repo `<r>`:

    capsule assistant ssh agent -- git -C /work/<r> status
    capsule assistant ssh agent -- git -C /work/<r> reset --hard
    capsule assistant ssh agent -- git -C /work/<r> clean -ffd

The failed job stays failed; resubmit it.

### Watching `clean_failed`

A failed clean after a collect is audited `clean_failed` (payload `reason`,
`message`) and changes nothing else, so the next job on that repo fails
`dirty_clone`: apply the remedy above. List them:

    nix shell nixpkgs#sqlite -c sqlite3 -readonly ~/.local/state/satan/runner/runner.sqlite \
      "select seq, at, job_id, json_extract(payload, '$.reason'), json_extract(payload, '$.message')
       from job_events where kind = 'clean_failed' order by seq desc limit 20"

A job's failure reason: `select id, state, json_extract(failure, '$.reason')
from jobs order by created_at desc limit 20`.

### Live checks (malebolge, env-gated, not in `just check`)

- `cd ~/dev/malebolge && SATAN_RUNNER_LIVE=1 just smoke-runner`: one `interactive`
  job on `goad-walk` (writes `SMOKE.md`) over the socket, followed to
  `needs_review`. Never promoted or rejected: it stays in quarantine.
  `just smoke-runner --slow` adds a 120 s sleep and prints `IN FLIGHT` for a
  room stop (reconnect check).
- `SATAN_RUNNER_LIVE=1 just smoke-runner-host-key`, with the deployed runner
  stopped: a scratch instance (own config, state, runtime dir) whose
  `known_hosts` is a tampered copy runs one job, expected `failed`/`host_key`
  from `preparing`. The real `known_hosts` is read only (sha256 compared).

### First deploy (SL-023 PHASE-12), in order

0. Pre-checks: `capsule assistant ssh agent -- ls /work` lists `goad-walk`;
   `llm-gateway list` (may need sudo) shows `satan-runner` allows
   `deepseek-flash`; `~/satan-corpus/prompts/patch-agent.md` exists and is
   reviewed.
1. `cd ~/flakes && just home-switch` (starts the unit parked).
   Agent: `systemctl --user status satan-runner --no-pager`; `systemctl --user
   show satan-runner -p ExecStart -p Environment -p LoadCredential -p
   ActiveState`; journal has no `refusing to start`; socket modes above; key
   absent from `-p Environment` and from `ps -o args` of the pid.
2. `capsule assistant start` if the room is down.
3. Confirm no producer submits (the PHASE-11 fence).
4. Enable (Switches above). Agent: journal shows the runner unparked.
5. `cd ~/dev/malebolge && SATAN_RUNNER_LIVE=1 just smoke-runner | tee /tmp/runner-smoke.txt`.
6. `SATAN_RUNNER_LIVE=1 just smoke-runner --slow | tee /tmp/runner-smoke-reconnect.txt`.
7. At `IN FLIGHT`: `capsule assistant stop`; wait for `waiting_room`;
   `capsule assistant start`; let it finish.
8. `systemctl --user stop satan-runner`.
9. `SATAN_RUNNER_LIVE=1 just smoke-runner-host-key | tee /tmp/runner-host-key.txt`.
10. `systemctl --user start satan-runner` (stays enabled).
