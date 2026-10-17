# Notes SL-013: Jailed pi and emacs devshell jails via the LLM gateway

Durable per-slice scratchpad — tracked in git. The place to lift anything from a
disposable phase sheet (`.doctrine/state/.../phase-NN.md`) that must survive
`rm -rf` before the slice close-out audit harvests it.

## Harvest
<!-- single-copy: updated in place each harvest; ids only, never restated content -->
fresh-as-of: 2026-10-17 · ready (plan, 6 phases, none started) · 5e7278b1

### Produced
- design.md locked (run rev 50); review RV-028 concluded, 5 findings verified.
- DEC-058, DEC-059, DEC-061, DEC-062, DEC-063 accepted; DEC-060 superseded by DEC-063.
- REV-009 — ADR-004 D4 admits imported constants; lands at reconcile.
- IMP-034 — remaining `~/dev/*` pi jails onto the gateway.
- plan.toml / plan.md — PHASE-01..06; phase sheets materialised.

### Learned
- mem.fact.pi.custom-provider-models-json — pi custom-provider gotchas.
- mem.fact.doctrine.design-apply-acceptance-records-design-accepted — top-level acceptance in reviewing logs design-accepted.
- EVD-003 — pi's DeepSeek compat needed and sufficient through LiteLLM.
- EVD-004 — empty models.json warns; `{"providers":{}}` clean.
- direnv `use flake_local` builds live `~/flakes/agents` in 13 devshells — memory candidate.
- `mem.fact.bwrap.pid1-environ-leak` last line wrong about emacs `jailed-shell` — correct at reconcile.

### Open
- POL-001 verification gateway line (design sec-7, reconcile).
- IDE-005 transcript purge (out of scope).
- Research baseline drift (design work only; see plan.md Notes) — restamp or leave at audit.

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

## Drafting spike: pi through the gateway (2026-10-17)

Why: pi's custom-provider models take `compat` and `thinkingLevelMap` only
from their own `models.json` entry (pi 1.3.0 `provider-composer.js`,
`modelFromJson`); LiteLLM's price map has neither. Outcome: DEC-063
supersedes DEC-060.

Setup: pi 0.99.1 (the installed build), unjailed, throwaway
`PI_CODING_AGENT_DIR`, `PI_OFFLINE=1`, eca's gateway key (allows
`deepseek-flash`). Variant A: provider `llm-gateway`, model with limits only.
Variant B: A plus pi's built-in `deepseek/deepseek-flash` `compat` and
`thinkingLevelMap`. Scripts and outputs were in the session scratchpad, not
kept.

| check | A (no compat) | B (pi's DeepSeek compat) |
|---|---|---|
| two sequential bash tool calls, `--thinking high` | works | works |
| reasoning prompt, `minimal`/`medium`/`high`/`xhigh`/`max` | all accepted | all accepted |
| `--thinking off` | ignored: 47 reasoning tokens | honoured: 0 |

pi's built-in DeepSeek compat, written for api.deepseek.com, works unchanged
through LiteLLM. Built-in values (pi 1.3.0 bundle): `compat = { supportsStore
= false; supportsDeveloperRole = false; maxTokensField = "max_tokens";
requiresReasoningContentOnAssistantMessages = true; thinkingFormat =
"deepseek"; supportsStrictMode = true; }`, `thinkingLevelMap = { minimal =
null; low = "low"; medium = null; high = "high"; max = "max"; }`,
`contextWindow = 1000000`, `maxTokens = 384000`, `input = [text image]`,
`reasoning = true`. Spend went to eca's ledger (a few cents).

## Design review (2026-10-17)

Policy adversarial-then-human. Adversarial pass RV-028 (Codex gpt-6-sol,
read-only, two rounds) concluded: 5 findings, all verified; history on the
ledger. Lasting change: no launcher seed for `models.json`, because a host-side
write on a jail-writable path follows a symlink the jail plants (reproduced).
The research home's `models.json` is tracked instead.

**A further pass would probe** only what no reading can settle: runtime
behaviour of the bind (bwrap creating the target, pi-research model
selection, nested pi's key), and pi 1.3.0 against 0.99.1. Those are VH 1–4
and the bump re-run, not another design review. None is needed before lock.
