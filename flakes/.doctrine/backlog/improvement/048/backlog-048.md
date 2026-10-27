# IMP-048: W6 — Quotient roots cover every /workspace repo

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

Programme W6. `~/.config/quotient/policy.src.json` `roots` lists 6 of the 14
`/workspace` repos as `~/dev/...` paths (plus emacs, `.local/src`, quotient).
Quotient canonicalises the call's cwd, so `/workspace/x` resolves to
`~/dev/x`.

Want: every `/workspace` repo is a root. Candidate: generate roots from
`/workspace/*` (resolved) in the justfile's `policy-install`, so the symlink
set is the single list.

Open: whether "aliases" means `/workspace` paths as root entries (check
whether quotient canonicalises root entries too) or just coverage.

## Open question answered (2026-10-27)

quotient canonicalises root entries too: `deepestRoot`
(`~/dev/quotient/src/server/profiles.ts:458`) puts each through `canonicalPath`
(realpath) on every call. A `/workspace/x` entry would work, but the policy
lists resolved paths: approvals and refusals are keyed by the resolved
`rootsEntry`, and a symlinked entry can be retargeted between calls
(`src/server/forms.ts:265`; `/workspace` is `root:wheel 775`). Resolving at
install time pins each root. So: coverage, not symlink entries.

## Scope widened (user, 2026-10-27)

Before W6 widens the roots, satan's supabase env must stop riding the
machine-default form. Evidence: satan's `just quotient-forms`
(`satan/justfile:77`) installs satan's forms (`projectOptions`: `SATAN_DB_HOST`,
`PG*` at 127.0.0.1:54322; packages: satan's dev set) at the policy's
machine-default paths, so every root without its own approval gets them.

User rulings:
- supabase env only where supabase is used: satan and satan-attrd, each by a
  project form (`.quotient/forms/*` + `quotient allow`).
- the machine default is generic: the lib's posture, base cli + git, just, jq,
  rg; no toolchains.
- built by a home-manager feature `agents.quotient` (option A); root input
  `quotient`, listed in `bin/dev-checkouts`. The server goes on PATH
  (`home.packages`) and replaces the npm install (`~/.npm-global/bin/quotient`):
  the MCP entries point at it, then `npm uninstall -g`.
- folded into this card.

## Plan

1. flakes: input `quotient` (follows nixpkgs-home); `bin/dev-checkouts` lists
   it. Feature `agents.quotient` (linux, requires `agents.gateway`, selected
   by `personal-linux`): `home.file` links `.local/state/quotient/forms/{read,write}`
   to the generic family; `home.packages` gets the server. Check:
   `quotient.lib.checkFormFamily` on the generic family.
2. satan: `quotient-forms` builds its project form into `.quotient/forms`
   (template pattern) and stops writing `~/.local/state/quotient`; its
   `.mcp.json` and `pi-report.sh` use `quotient` on PATH; then
   `quotient allow ~/dev/satan` (operator).
3. satan-attrd: quotient input; project form with `DATABASE_URL` (its
   Justfile's 127.0.0.1:54322 DSN); `quotient allow` (operator).
4. `~/.config/quotient/justfile`: `policy-install` generates `roots` = source
   roots (emacs, `.local/src`, quotient) ∪ `realpath -e /workspace/*`, nested
   entries dropped (`/workspace/docs` is inside doctrine), sorted; `diff`
   compares the generated policy with the installed one.
5. MCP: the global and doctrine-project `quotient` entries in `~/.claude.json`
   run the nix `quotient`; `npm uninstall -g quotient`.
6. Verify: all 14 covered; a call from a new root (goad) accepted and its form
   carries no `PG*`/`SATAN_DB_HOST`; satan's call carries them.

Noted, out of scope: satan-attrd's jails still forward `DOCKER_HOST` and
bind the docker socket, against CHR-023's no-container-socket ruling;
screwtape's own `quotient` input could follow the new root input.

## Progress (2026-10-27)

Done, verified:
- flakes: input `quotient` (lock adds only it; `nix flake lock` also moved
  `emacs-overlay`, reverted by hand: its `inputs.emacs-overlay.url` override
  re-resolves on every lock). `agents.quotient` feature + `quotient/family.nix`
  (`commonPkgs ++ [just]`; the lib now exports `commonPkgs`).
  `checks.quotient-forms` passes and is in `just test`; `perSystem.nix` takes
  `{inputs}`. The generic write form's launcher sets only posture and gateway
  env (no `PG*`, `SATAN_DB_HOST`). `just test` green; coverage green except
  `base@aarch64-linux` (pre-existing since 85686442: base sets
  `users.users.david.shell = pkgs.zsh` without `programs.zsh.enable`); isolation ok.
- home switched: `quotient` 0.6.1 on PATH (`~/.nix-profile/bin`), generic forms
  at `~/.local/state/quotient/forms/{read,write}`. satan's old out-links there,
  and `pkg`, `bin/quotient`, removed (home-manager refused to clobber them).
- satan: `quotient-forms` links `.quotient/forms` (screwtape's recipe);
  hostile audit runs those; `.mcp.json`, `pi-report.sh` (`command -v`, tested)
  and CLAUDE.md use `quotient` on PATH. Forms built (same store paths as before).
- satan-attrd: input `quotient`; agents relocked to 91b5b098 (its old pin lacked
  `quotientFormFamily`; every package still evaluates); project forms with
  `DATABASE_URL` (the Justfile's DSN) and `LD_LIBRARY_PATH`;
  `checks.quotient-forms` passes; `just quotient-forms`; forms built.
- `~/.config/quotient/justfile`: `policy` generates (`roots_from` in the source
  → resolved links ∪ resolved `roots`, nested dropped, sorted); `policy-install`
  and `diff` use it; `just test` covers it (3 cases). `policy.src.json` now
  lists the 3 non-/workspace roots plus `roots_from: "/workspace"`; generated:
  16 roots. `doctrine.policy.src.json` unaffected (no `roots_from`).
- MCP: user and doctrine-local `quotient` entries run `quotient` from PATH;
  `npm uninstall -g @davlee/quotient`.

Left:
- operator: `quotient allow` for ~/dev/satan (until then satan's calls get
  the generic form); `just policy-install` in ~/.config/quotient; then
  `quotient allow` for ~/dev/satan-attrd (allow refuses a path outside the
  installed policy's roots, and satan-attrd is a root only once it is
  installed); restart MCP clients.
- verify: a call from goad accepted, generic form; satan's carries `PG*`.
- commits (flakes, satan, satan-attrd; push agents so satan-attrd and the root
  lock can follow `commonPkgs`).

## Verified live, closed (2026-10-27)

Operator steps done by the user: `quotient allow` for satan, `just
policy-install`, `quotient allow` for satan-attrd. Installed policy equals
`just policy` (16 roots); approvals.json names exactly the built project
forms. One `read` call each, `env | grep -E '^(PG|SATAN_DB|DATABASE_URL)'`:

| root | form | env |
|---|---|---|
| goad (new root) | machine default | none (grep exit 1) |
| satan | project | `PGHOST PGPORT PGUSER PGPASSWORD SATAN_DB_HOST` |
| satan-attrd (new root) | project | `DATABASE_URL` (…@127.0.0.1:54322) |

Follow-ups, not this card: push `~` so locked builds see the lib's
`commonPkgs`; `base@aarch64-linux` coverage (zsh shell without
`programs.zsh.enable`, since 85686442); satan-attrd's docker socket and
`DOCKER_HOST` forward (against CHR-023's ruling).
