# IMP-034: Move the remaining ~/dev/* project flakes' pi jails onto the LLM gateway

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

SL-013 moves pi onto the gateway in the emacs flake, `~/dev/doctrine` and the
agents template. About 17 other `~/dev/*` flakes still build `makeJailedPi`
with provider keys through `op run`. Each needs `gateway =
jailLib.gatewayClient "pi";` (or `mkJail` default), its dirge/opencode jails
deleted or opted out, and a re-lock of `agents`. Pattern: SL-013 design §4.
satan is separate (IMP-030).
