# Jailed pi and emacs devshell jails via the LLM gateway

## Context

SL-011 built the LLM gateway (LiteLLM on `127.0.0.1:4000`, per-client keys,
budgets) and moved only the jailed eca onto it. IMP-028 is the fast follow:
pi is the harness in daily use, and it still gets provider keys.

Two leaks remain:

```
op run ──7 provider keys──> jailed-pi / jailed-shell / jailed-claude …   (emacs flake, project flakes)
~/.local/share/jail.nix/home/agent/.pi/agent/auth.json
    └─ "deepseek" stored key ──> bound into every specDev pi jail; beats any injected key
```

**The emacs flake's jails** (`~/.config/emacs/flake.nix`, the devshell Emacs
runs in) are not a separate jail implementation. They are built with
`agents.lib.mkJailedAgents` (`makeJailedPi`, `makeJailedAgent` for
`jailed-shell`, …). Its `flake.lock` pins `agents` at `27d0ecbe`, older
than gateway mode and the bwrap empty-environment fix (`b17e348a`, memory
`mem.fact.bwrap.pid1-environ-leak`). But its `.envrc`, like
`~/dev/doctrine`'s and 10 other `~/dev/*` flakes', runs
`use flake_local agents …` (`modules/home/programs.nix:20-35`), which
overrides `agents` with `path:~/flakes/agents`. In those direnv devshells
the live `agents` is built, so a change there lands on the next reload, with
no push or re-lock. The lock matters only outside direnv (`nix build`,
`nix run`, a shell entered without it). The "seven provider keys" are
`agents`' default `apiKeys` map (DeepSeek, OpenRouter, Mistral, Voyage,
OpenAI, Gemini, JEV), injected by `op run` (`useOpEnv`, on for the `specDev`
profile) or forwarded from the caller (`jailed-pi`: `passApiKeysFromEnv`,
fed by the Emacs patch-agent adapter's `my/op-read-env`).

## Scope & Objectives

1. **pi gateway mode** in the `agents` sub-flake (DEC-058): when gateway mode
   is on and the pi binary is in the jail, as agent or subagent, bind a
   Nix-generated `models.json` read-only over the shared one, after
   persist-home. One provider, `llm-gateway`: literal `baseUrl` from
   `gateway.url`, `"apiKey": "$LLM_GATEWAY_KEY"` (DEC-049 unchanged). Its
   models are generated from the served-model list, each model carrying a
   hand-written pi entry with its `compat` and `thinkingLevelMap` (DEC-063,
   superseding DEC-060). Opt-in, off by default: the sub-flake is published.
2. **Gateway constants move into `agents`** (DEC-059): `agents/gateway.nix`
   holds the constants and the served-model list; the root's
   `features/agents/gateway/constants.nix` and `proxy.nix` defaults import
   it. `jailLib.gatewayClient "<client>"` builds a jail's `gateway` value;
   eca switches to it.
3. **Template and `~/dev/doctrine`** (DEC-062): every jail defaults to
   `gatewayClient "pi"` (doctrine through `mkJail`). Doctrine deletes
   `jailed-dirge`; the template drops `jailed-opencode` and `jailed-gemini`.
4. **Emacs flake** (DEC-061): `jailed-pi`, `jailed-pi-research`,
   `jailed-claude`, `jailed-shell` use `gatewayClient "pi"`; no `op run`
   anywhere (`jpi` included); delete `jailed-opencode` and `jailed-dirge`;
   drop the `OPENROUTER_API_KEY` forward. Re-lock `agents` after the push.
5. **Shared pi dir**: edit the tracked `settings.json` to
   `llm-gateway/deepseek-flash` (OQ-5); extend its tracked `.gitignore` to
   `models.json*` and `models-store.json`. Track `{"providers":{}}` as the
   research home's `models.json`, so no gateway run leaves an empty bind
   target there.
6. **Rotate the DeepSeek key early and remove the stored keys in the same
   step** (POL-001 rule 6, "on a leak, rotate first"; order in the run's
   inq-9): `auth.json` `deepseek` and `llama.cpp`, and `local-llama`'s
   literal key in `models.json`, `models.json.backup` and `models.json~`.
   The OAuth logins (`openai-codex`, `google-gemini-cli`,
   `google-antigravity`) stay.
7. **Issue one shared key**, alias `pi`, `deepseek-flash`, $50 lifetime
   budget; document in README § LLM gateway and `agents/README.md` § Gateway
   mode.

## Non-Goals

- New gateway providers or models (IMP-029). If pi needs more than
  `deepseek-flash` to stay usable, that is a sequencing question (OQ-2), not
  scope here.
- Migrating every `~/dev/*` project flake (≈17 use `makeJailedPi`). One is
  done here; the rest is a follow-up backlog item.
- OAuth/subscription harnesses (claude, codex): they sign in their own way.
- satan (`~/dev/satan`: its `jailed-pi`, gptel harness jail, patch adapter,
  satan-patcher): the same pattern as this slice, so it reuses the mechanism,
  but in a follow-up, IMP-030.
- Emacs's own gptel (`~/.config/emacs/apps/dl-gptel.el`): in-process and
  unjailed, like the unjailed eca.
- The unjailed `eca`, and jails off this host.

## Affected surface

| path | change |
|---|---|
| `agents/gateway.nix` (new) | constants, served-model list, `gatewayClient` |
| `agents/jailed-agents.nix`, `agents/jailed-agents-test.nix` | pi `models.json` bind and generation |
| `agents/flake.nix` | export `gatewayClient` if not via `mkJailedAgents` |
| `agents/README.md` | pi in § Gateway mode |
| `features/agents/gateway/constants.nix`, `proxy.nix`, `features/agents.nix` | import from `agents`; eca via `gatewayClient` |
| `features/agents/gateway.nix` | `services.llm-gateway.models` option removed; reads the file's list |
| `_templates/agents/flake.nix` | gateway by default; stale comments |
| `README.md` § LLM gateway | clients, "what it does not cover" |
| `~/.local/share/jail.nix/home/agent/.pi/agent/{settings.json,.gitignore}` | tracked in `~` |
| `~/.local/share/jail.nix/home/agent-research/.pi/agent/models.json` (new) | tracked in `~` |
| `~/.local/share/jail.nix/home/agent/.pi/agent/{auth.json,models.json}` | untracked; manual key removal |
| `~/.config/emacs/flake.nix`, `flake.lock` | separate repo |
| `~/dev/doctrine/flake.nix`, `flake.lock` | separate repo |

## Risks & assumptions

- **A1** (confirmed in research, P1, P2): pi reads a custom provider's
  `apiKey` from an env var, and a stored `auth.json` key for the same
  provider name wins over it.
- **R1**: direnv consumers build live `~/flakes/agents`, so an `agents`
  change reaches the Emacs devshell and 11 project devshells on their next
  reload, before any of them opt in. Gateway mode must stay off by default,
  and a break in `agents` breaks all of them at once.
- **R2**: `use_flake_local` overrides with `path:`, not `git+file`, so
  untracked files in `agents/` reach those builds; and it watches only
  `agents/*.nix` and `flake.lock`, so a change in a subdirectory does not
  trigger a reload.
- **R3**: the emacs flake and `~/dev/*` are outside this flake's
  `just test`; their verification is by evaluation/build and by hand.

## Open questions

Settled by the user, 2026-10-17:

- **OQ-1** One shared pi gateway key. Every pi jail shares one pi home, so
  per-jail keys would be security theatre.
  *Amended 2026-10-17:* theatre for isolation only. The shared pi home holds
  writable code, so a jail compromised once can read the next jail's key
  however keys are split. Per-jail keys would still give attribution,
  independent revocation and separate budgets. The shared key stays, as a
  convenience tradeoff (DEC-061).
- **OQ-2** `deepseek-flash` is enough for now; IMP-029 is not a prerequisite.
- **OQ-3** Emacs flake: no `op run` for any jail. Make it easy to give a jail
  its own gateway key later. `jailed-pi-research` may share pi's key or get
  its own. claude signs in by OAuth. Delete `jailed-opencode` and
  `jailed-dirge` (not in use).
- **OQ-5** Model selection: edit the shared, tracked `settings.json` to the
  gateway model. That every pi jail is affected is wanted: it forces the
  rest to upgrade. Once the gateway serves more than one model, the
  selection should follow what LiteLLM serves.
  *Amended 2026-10-17:* the edit sets the default; it does not force an
  upgrade. When the saved model is unavailable, pi silently uses the first
  model it holds credentials for, possibly an OAuth subscription model
  (pi 1.3.0 `model-resolver.js` ~:397-427). The edit moves to the cutover,
  and live checks record what an unmigrated jail falls back to (inq-9).
- ~~OQ-4~~ Settled: `my/op-read-env` does not feed jails; the patch adapter
  is satan's (IMP-030).

## Verification intent

- `agents` tests: a gateway-mode pi jail carries no provider key (env, PID 1
  environ, fds) and holds a `models.json` provider pointing at the gateway
  URL (VT).
- Emacs flake and `~/dev/doctrine` evaluate and build, through direnv and
  from the lock (VT/VA).
- Live: jailed pi completes a request through the gateway and its spend
  shows in `llm-gateway list`; `/proc/1/environ` and `auth.json` inside the
  jail hold no provider key (VH).
- The old DeepSeek key is rotated and the old one rejected (VH).

## Summary

Bring pi, and every jail the Emacs devshell builds, onto the gateway path
SL-011 opened, and close the stored-key leak in pi's shared `auth.json`.

## Follow-Ups

- IMP-034: migrate the remaining `~/dev/*` project flakes' pi jails.
- IMP-030: satan's jails and patcher.
