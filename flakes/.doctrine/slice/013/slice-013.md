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

1. **pi gateway mode** in the `agents` sub-flake: `makeJailedPi` accepts the
   existing `gateway` argument and gives pi a `models.json` provider pointed
   at the gateway, with the API key read from the per-jail key file (bound
   read-only; `!command` form). Opt-in, off by default: the sub-flake is
   published.
2. **Template and `~/dev/doctrine`** (the first project flake, user's
   choice) use it.
3. **Emacs flake**: move `jailed-pi` to gateway mode, and stop handing
   provider keys to jails that need none. Re-lock `agents` too, so builds
   outside direnv match. Which
   jails get gateway keys and which get no keys is a design decision (OQ-3).
4. **Remove the stored `deepseek` key** from the shared pi `auth.json`, then
   rotate it (POL-001 rule 6). The OAuth logins in that file
   (`openai-codex`, `google-gemini-cli`, `google-antigravity`) stay; they
   cannot go through an API-key gateway.
5. Issue gateway keys for the new clients; document in README § LLM gateway
   and `agents/README.md` § Gateway mode.

## Non-Goals

- New gateway providers or models (IMP-029). If pi needs more than
  `deepseek-flash` to stay usable, that is a sequencing question (OQ-2), not
  scope here.
- Migrating every `~/dev/*` project flake (≈17 use `makeJailedPi`). One is
  done here; the rest is a follow-up backlog item.
- OAuth/subscription harnesses (claude, codex): they sign in their own way.
- The unjailed `eca`, and jails off this host.

## Affected surface

| path | change |
|---|---|
| `agents/jailed-agents.nix`, `agents/jailed-agents-test.nix` | pi gateway mode |
| `agents/README.md` | pi in § Gateway mode |
| `_templates/agents/flake.nix` | template uses gateway mode |
| `~/.config/emacs/flake.nix`, `flake.lock` | lock bump, jail options |
| `~/.config/emacs/lisp/` (patch-agent adapter) | if `my/op-read-env` key forwarding goes |
| `features/agents/gateway/constants.nix` | key paths for new clients, if needed |
| `README.md` § LLM gateway | clients, "what it does not cover" |
| `~/.local/share/jail.nix/home/agent/.pi/agent/auth.json` | untracked; manual edit + rotation |
| `~/dev/doctrine/flake.nix` | separate repo |

## Risks & assumptions

- **A1**: pi honours a custom OpenAI-compatible provider in `models.json`
  with a `!command` API key, and a stored `auth.json` key for the same
  provider name would win over it (SL-011 research C4, C5). Verify in
  research.
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

- **OQ-1** One gateway key per pi jail (per project, per emacs) or one shared
  pi key? Per-jail gives per-project budgets and revocation; it costs a
  key-issue step per project.
- **OQ-2** Which models does pi actually use day to day? If not
  `deepseek-flash`, pi loses them under the gateway until IMP-029 lands.
- **OQ-3** Emacs flake, per jail: `jailed-shell`, `jailed-claude`,
  `jailed-opencode`, `jailed-dirge`, `jailed-pi-research` — gateway key,
  no key, or keep `op run` for now?
- **OQ-4** Does the Emacs patch-agent adapter's `my/op-read-env` path still
  have a job once `jailed-pi` uses the gateway?

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

- Backlog: migrate the remaining `~/dev/*` project flakes' pi jails.
