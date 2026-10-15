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
