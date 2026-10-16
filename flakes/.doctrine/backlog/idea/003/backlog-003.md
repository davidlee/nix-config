# IDE-003: Harness-agnostic credential broker for agents

Agents should not hold raw API keys at all. A broker or proxy on the host
holds credentials; the jailed agent talks to it (e.g. a local
OpenAI-compatible endpoint that injects the key upstream), and sees no
secret to leak.

- Survey existing brokers and agent proxies first, including pi-specific
  ones, before building.
- Must be harness-agnostic: pi, codex, claude, crush, opencode, … under
  `agents/jailed-agents.nix`.
- Supersedes the env-var path that IMP-020 tightens.
- Related: IDE-004 (same boundary, for git).

## Survey and direction (2026-10-16)

- **pi-model-proxy** (BlackBeltTechnology): wrong direction. It exposes pi's
  own logged-in models outward as an OpenAI/Anthropic-compatible API, so the
  pi running it holds the credentials. It's pi-only and small (4 stars).
- **pi-auth-broker** (pi.dev): shares OAuth token refresh for Anthropic and
  Codex logins. Clients still receive short-lived access tokens, and it
  doesn't cover API-key providers like DeepSeek. Not relevant.
- **LiteLLM proxy** (in nixpkgs): the chosen direction. A host-side,
  OpenAI-compatible gateway that holds the real keys and gives each client a
  revocable virtual key, limited to certain models and with its own budget
  and spend log. It supports DeepSeek and OpenRouter, and works with any
  harness.

**One system service, many clients:** jailed agents, the SATAN proposal VM
(satan IDE-007), satan-tick, gptel. Side effects: it also fixes satan ISS-023
(prompt-mode runs lost when the 1Password dialog times out; the service
unlocks once at start) and satan ISS-029 (jail keys leak through argv; budget
ceiling dropped).

Open:
- Virtual keys and spend tracking need Postgres. Prove that the nixpkgs
  package's database setup works before relying on it.
- The master key stays out of every client's reach, Emacs included.
- The satan ADR-017 authority ledger changes owner for credential resolution.
- **Serve on a unix socket, with access controlled by its file mode.**
  Required by oubliette's Plan F (`docs/plan-f-assistant.md`, oubliette
  `fb241c4`): the SATAN room reaches LiteLLM through a forwarder in its network
  namespace that connects to the socket, so nothing routes from guest to host.
  The socket's owner, group and mode are this repo's to set, and they decide
  which local clients may reach the proxy. Check that LiteLLM (or the nixpkgs
  service) can listen on a unix socket; if not, it needs a TCP-to-socket shim
  bound to loopback only.
