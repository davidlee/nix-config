# IMP-030: Move satan's jails and patcher onto the LLM gateway

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

Follow-up to SL-013 (pi gateway mode). satan (`~/dev/satan`) is the same
pattern as SL-013, not like Emacs's in-process gptel: it builds jails with
`agents.lib.mkJailedAgents` and forwards plaintext provider keys into them
(`useOpEnv = false; passApiKeysFromEnv = true`). The elisp resolves keys
only to feed those jails. Emacs's gptel (`~/.config/emacs/apps/dl-gptel.el`)
calls providers in-process, unjailed, with OAuth and `my/op-key`; it stays
out, like the unjailed eca.

Surfaces (SL-013 research, findings 6, 7):

- `jailed-pi` (`~/dev/satan/flake.nix:231-248`): gateway mode, once SL-013
  lands it in `agents`.
- `satan-jailed-gptel-harness` (`flake.nix:~297-307`): gptel inside a jail,
  fed keys by the Emacs broker. Needs a gptel backend at the gateway reading
  `LLM_GATEWAY_KEY`.
- Patch adapter `satan-patch-adapter-pi-api-key-vars`
  (`satan/satan-patch-adapter-pi.el:32-44`) and the runner's readiness gate
  over it (`satan-patch-runner.el:252-314`): empty or drop once jailed-pi
  needs no provider key.
- satan-patcher daemon (`~/flakes/features/satan/patcher.nix`, `apiKeyRefs`
  OPENROUTER + DEEPSEEK; `nix build <repo>#jailed-pi` per job, from satan's
  lock, not direnv).
- `jailed-shell` and other jails exposing `pi` as a subagent.

Depends on IMP-029 if satan needs OpenRouter models through the gateway.
