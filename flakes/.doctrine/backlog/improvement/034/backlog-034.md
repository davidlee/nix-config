# IMP-034: Move every remaining ~/dev/* project flake's jails off provider keys

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

SL-013 moved pi onto the gateway in the emacs flake, `~/dev/doctrine` and the
agents template; satan:SL-022 did satan (IMP-030). The other `~/dev/*` flakes
still build jails with provider keys through `op run`.

**Widened 2026-10-19** from pi jails to every jail. Codex `.tmp` files held
provider keys in curl headers (IDE-005), so pi alone does not close the leak.
Per flake:

- pi: `gateway = jailLib.gatewayClient "pi";` (or the flake's `mkJail` default).
- claude, codex: OAuth, no provider key; `apiKeys = []` once IMP-020 flips the
  default.
- opencode, dirge and other key-only jails: delete, or put on the gateway.
- re-lock `agents`.

Order: panopticon, goad, satan-attrd, www, retrograde; then agentdoc, bough,
forgettable, vk, lazyspec, spec-driver, org-incremental-writing. Check whether
checkout-doctrine, doctrine-SL-248 and goad-009-proto are still live; delete
rather than migrate if not.

Closes the vector IDE-005 found; IDE-005's purge and rotation follow.

**Progress 2026-10-19.** On the gateway: panopticon
(opencode jail deleted), goad (its own fd key forwarding deleted), satan-attrd,
retrograde (opencode and gemini jails deleted). Each also dropped
`try-fwd-env "*_API_KEY"` extraOptions, which forward keys outside `apiKeys`.
Every lock was already at ea3cf561, which has `gatewayClient`, so none
re-locked. Verified by building each jail: no `op run`, no `API_KEY`, one
`LLM_GATEWAY_KEY`. www: dirge has no gateway config, so its jail and claude
subagent slot are deleted (user's choice); unjailed dirge stays. Committed:
panopticon 116b57e, goad 272685a, satan-attrd 3eff42e, retrograde ee81335,
www 7d8352f.

**Progress 2026-10-19 (2).** Also on the gateway: bough 65ef289d (vk is a
symlink to it), forgettable 9d19535, org-incremental-writing 1693fe7,
spec-driver b58fd442 and agentdoc 5a6c22e (both off the `pub` shim, `agents`
re-locked at add489ed). Deleted as stale: checkout-doctrine, doctrine-SL-248
(commits all in ~/dev/doctrine), goad-009-proto (worktree removed; branch
`slice-009-prototype` kept in goad). Left: lazyspec. Its committed flake has no
jails; its uncommitted flake.nix is a copy of another repo's (description
"satan-attrd", builds doctrined, jails forwarding OPENROUTER_API_KEY). Its
owner decides whether to discard it.

**Resolved 2026-10-19.** lazyspec deleted by its owner. Every `~/dev/*` flake
that builds jails now takes `gatewayClient "pi"`; none references a provider
key.
