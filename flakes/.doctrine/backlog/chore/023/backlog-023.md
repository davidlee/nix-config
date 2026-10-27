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

## Ready repos migrated (2026-10-27)

Option 1 of the W5 split: every repo but panopticon and satan. IMP-047 had
already put every `.envrc` but satan-corpus's on the helper, and W1's rw
moves were done or reverted (above), so what remained was the template's
`agents.inputs.nixpkgs.follows = "nixpkgs"`, satan-corpus's `.envrc`, and
two stale locks.

| repo | change | commit |
|---|---|---|
| retrograde, satan-attrd, www, goad, malebolge, oubliette, doctrine, bough (vk), forgettable, spec-driver, notes | agents follows nixpkgs; relock | one each |
| org-incremental-writing | same; agents lock bumped to a369b021 (the old lock predated `workspaceDepsRw`, so a pure eval failed) | cd32580 |
| satan-corpus | same; `.envrc` onto `use agents_dev`; agents lock bumped (same reason) | ea1efe7 |
| screwtape | nothing: already follows and uses `quotientFormFamily` | — |

Verified: every devshell evaluates against both the locked and the local
agents; `jailed-pi` builds against the local agents in the 11 repos that
export it. The `follows` costs little: www's `jailed-pi` needs 5 builds on its
own nixpkgs against 4 on the agents pin. Commits are scoped to
`flake.nix`/`flake.lock` (and satan-corpus's `.envrc`); nothing pushed.

Kept: oubliette and screwtape stay on `use flake` (no live input wanted).

Left:
- form step: satan's hand-rolled family (doctrine's is done, below).
- satan-corpus: still off the gateway (`useOpEnv = false;
  passApiKeysFromEnv = true`), with IMP-051's op consumers.
- panopticon and satan, after IMP-051.

## doctrine's form (2026-10-27, after IMP-052)

doctrine `0b683c3df`: `quotientForms` is `jailLib.quotientFormFamily`
(prefix `doctrine-quotient`, so the policy's form paths hold);
`projectOptions = c: [ … ]` is the one project half for jails and forms;
`checks.quotient-forms` runs `quotient.lib.checkFormFamily`. quotient input
follows `main` unpinned (user: a break should surface). The form no longer
binds the persisted jail home; the jails keep it.

Found by the check: jail.nix `try-fwd-env` renders `${NAME+…}` on the bwrap
line, which quotient's check refuses. New `jailLib.tryFwdEnv c NAME`
(53ffeefa) appends `--setenv` to `RUNTIME_ARGS` instead; tested in
`jailed-agents-test.nix` and live (`jailed-shell`: set → forwarded, unset →
absent). Use it in any shared project half.

Verified: jail drvPaths identical before/after the flake.nix change on the
same lock; both forms build; the check passes; `doctrine-quotient-read
<session> --version` launches (pi 1.4.0); the launcher carries the posture
(host doctrine, ssh-push block, git identity, guarded git), both forwards,
`TERM=dumb` and the gateway.

Operator steps, done by the user (2026-10-27):
`just quotient-forms` in doctrine (installs the new forms at the policy's
paths) and `exposure: []` in `~/.config/quotient/doctrine.policy.json` (was
`["~/.local/share/jail.nix/home/agent"]`, now unused).

doctrine CHR-183: builder half recorded done (`77cec7966`); its ISS-001 half
stays open.

## After IMP-051 (2026-10-27)

IMP-051 done: the gateway is a jail's only model access (`497d1f56`, the
receipt), and the jail scan is the lib's (`mkJailScanCheck`, `opUnjailed`).
Its CHR-023 parts: satan-corpus on the gateway (`de38a66`), panopticon's
`jpi` without `op run` (`a5b49ff`), satan's scans on the lib (`5d349fd`,
agents relocked).

Left:
- (done, below) satan's form: its hand-rolled `quotientFormFamily` (`flake.nix:325`) and
  `quotientFormsCheck` onto `jailLib.quotientFormFamily` + one
  `projectOptions`, as doctrine did; quotient input unpinned (was `v0.3.1`;
  user, 2026-10-27).
- ISS-019 (`~/.emacs.d` gone; bwrap refuses jails that bind it) in satan and
  satan-corpus at least; the other five repos are one-line chores.
- panopticon: `agents.inputs.nixpkgs.follows`; relock.
- satan-corpus: live check of a gateway jail once ISS-019 lets it start.

## satan's form (2026-10-27)

satan's hand-rolled `quotientFormFamily`, `formProbes` and
`quotientFormsCheck` are replaced: the forms are
`jailLib.quotientFormFamily { prefix = "quotient"; packages = projectPkgs;
options = projectOptions; }`, and `checks.quotient-forms` is
`quotient.lib.checkFormFamily` (satan DEC-116: the form contract is
quotient's; SL-029's residue property is its rule (f)). quotient follows
`main` unpinned (v0.6.1; the server bumps with it, policy schema unchanged at
`quotient-policy/2`).

User rulings: `projectOptions` (shared by the dev jails and the forms) is the
supabase env only; satan-corpus stays in the jails; the Emacs server socket
is gone from every jail; no container socket anywhere (the podman socket was
dead on this host, and a live docker socket would let a delegate mount any
path), and `.envrc`'s stale `DOCKER_HOST` is gone. Forms have no persisted
home; the jails keep theirs. The posture is accepted for every root the host
policy allows.

Verified: jail drvPaths unchanged except the three on `jailEnvOptions`
(jailed-pi, -claude, -shell), whose launchers lose exactly `DOCKER_HOST`, the
podman bind and the Emacs server bind; every check builds (quotient-forms,
harness and malebolge profiles, runner-socket-unjailed, op-unjailed); the
devshell evaluates locked and against the live agents; `quotient-read
<session> --version` launches (pi 1.4.0). satan's IMP-048 (gap 2 closed by
rule (g)) and SL-029 notes record the move.

Operator steps (the user's): `just quotient-forms` in satan (installs the
forms and the 0.6.1 server), `exposure: []` in `~/.config/quotient/policy.json`
and `policy.src.json`, restart the quotient MCP server, `quotient allow` per
root if approvals pin the old forms' hashes; optionally `just
quotient-hostile-audit`.
