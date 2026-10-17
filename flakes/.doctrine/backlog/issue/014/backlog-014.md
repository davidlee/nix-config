# ISS-014: Gateway missing-key hint names the jail, not the client key file

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

`agents/jailed-agents.nix` (the gateway wrapper's missing-key hint) prints
`llm-gateway issue ${name} … --out <key_file>`, with `${name}` the jail name.
Two ways it misleads:

- Shared client key: after SL-013 PHASE-05, jailed-claude, jailed-shell and
  jailed-pi-research read `keys/pi`, but the hint says `issue claude` etc.
- After a rotation: the alias in the hint (e.g. `pi`) is revoked, and a revoked
  alias is never reissued (DEC-051). The hint should name the key file and say
  to pick a fresh alias, not suggest one.

Seen live 2026-10-17 (SL-013 PHASE-06) after rotating `pi` → `pi-2`.
