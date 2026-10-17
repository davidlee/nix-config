# Notes SL-013: Jailed pi and emacs devshell jails via the LLM gateway

Durable per-slice scratchpad — tracked in git. The place to lift anything from a
disposable phase sheet (`.doctrine/state/.../phase-NN.md`) that must survive
`rm -rf` before the slice close-out audit harvests it.

## Harvest
<!-- single-copy: updated in place each harvest; ids only, never restated content -->
fresh-as-of: 2026-10-17 · design/inquiring rev 15 · 72b9bffe

### Produced
SL-013 scope; IMP-030; DEC-058, DEC-059, DEC-060, DEC-061, DEC-062 (accepted);
IMP-029 price-map-lag addendum; research artefact (gitignored).

### Learned
- direnv `use flake_local` builds live `~/flakes/agents` in 13 devshells
  (`modules/home/programs.nix:20-35`) — memory candidate.
- pi takes `baseUrl` verbatim; only `apiKey`/headers interpolate
  (pi 1.3.0 `provider-composer.js:88,139,291`) — memory candidate.
- `mem.fact.bwrap.pid1-environ-leak` last line is wrong about emacs
  `jailed-shell` (built with agents' jail) — correct it.

### Open
- Design gate `sufficiency-accepted` (user) pending.
- POL-001 verification/scope revision candidates (research Thread 1).
- IDE-005 transcript purge (out of scope).

## Design triage (2026-10-17, explore stage)

Evidence: `research/research.md` (gitignored; raw threads under `research/raw/`).

### Constraining governance

POL-001 r1 (no key in store/template/literal), r3 (`$HOME` worktree; shared
pi dir partly tracked), r4 (least privilege), r6 (rotate). ADR-004 D4
(gateway values are constants; the published `agents` sub-flake does not
import the root's). DEC-049 (key as `LLM_GATEWAY_KEY` over FD 22, opt-in),
DEC-050 (key issue via sudo CLI), DEC-051 (model allow-list, priced only).
DEC-037/038 (lock vs override). IMP-020 (default `apiKeys` still all seven).

### Shaping decisions already made (user, 2026-10-17)

- Pi config: Nix-generated `models.json`, bound read-only (research option b).
- One shared pi gateway key; `deepseek-flash` only for now.
- Emacs: no `op run` anywhere; easy per-jail key later; delete opencode, dirge.
- Shared `settings.json` edited to the gateway model, deliberately global.
- Stored keys removed: `auth.json` `deepseek`, `llama.cpp`; `models.json`
  `local-llama`. DeepSeek rotated.
- satan → IMP-030; Emacs gptel out (in-process, unjailed).

### Open design questions

1. How pi's gateway config reaches a jail: file content, generation, bind
   placement, and when it applies. Nested pi runs as a bare binary inside
   the parent jail (`agents/jailed-agents.nix:408-430`), so the rule must
   cover pi as a subagent, not just as the agent.
2. Where out-of-tree flakes get gateway values (url, run directory, key
   path) without breaking ADR-004 D4 or duplicating constants; must make
   "a jail gets its own key later" a one-line change.
3. Which models the generated `models.json` lists, with what metadata, and
   how that list follows the gateway's (now one model; later sync).
4. Emacs jail set and options after the change.
5. Doctrine flake and template shape (doctrine's `mkJail` helper).
6. Operational sequence: key issue, `settings.json`, stored-key removal,
   `.gitignore` for the shared pi dir, rotation, live checks.
7. Test strategy (VT in `agents/jailed-agents-test.nix`).
8. pi's pi.dev calls (`PI_SKIP_VERSION_CHECK`, `PI_TELEMETRY=0`): in or out.

### Risks

- An `agents` change reaches 13 direnv devshells on reload (research F7).
- Research home `agent-research` has an empty `settings.json` and
  `auth.json`: pi-research relies on the bound `models.json` alone.
- pi 1.3.0 (locked, unbuilt) may differ from 0.99.1; re-verify on bump.

### Assumptions

- A1: bwrap `--ro-bind` of a file over a path inside the persisted-home bind
  wins when placed after it (precedent `agents/jailed-agents.nix:152-158`).
- A2: with one provider in `models.json` and no settings, pi starts on that
  provider's first model (research P6, unverified at source).
