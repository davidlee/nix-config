# IMP-037: Gateway launcher hint names the jail, not the gateway client

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

Found in satan:SL-022 research. When the key file is missing, the gateway
launcher's hint (`agents/jailed-agents.nix`, `gatewayOuter`) prints
`llm-gateway issue <jail name> …`, but the key belongs to the gateway
*client* named in `gatewayClient "<client>"`. For satan's harness it prints
`issue satan-gptel-harness … --out …/keys/satan`; for `jailed-shell` /
`jailed-pi-research` it prints `shell` / `pi-research` instead of `pi`. The
`--out` path is right. Cosmetic: derive the alias from the key file's
basename.
