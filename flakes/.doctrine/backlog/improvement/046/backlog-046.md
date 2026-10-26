# IMP-046: W3 — Agents lib helper for quotient confinement forms

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

Programme W3. Three implementations of a quotient form family exist:
- screwtape: `quotient.lib.mkFormFamily { pkgs; jail-nix; pi = jailLib.unjailed.pi; packages; env.LLM_GATEWAY_URL; secretEnv.LLM_GATEWAY_KEY; piFiles."models.json" = jailLib.piGatewayModels; }` — ~10 lines, the newest pattern.
- satan: hand-rolled `quotientFormFamily` on `makeJailedPi`.
- doctrine: an "interim copy" of satan's, already marked for retirement
  (`doctrine:CHR-183`).

Want: a helper in the agents lib that wraps `mkFormFamily` with the gateway
wiring, so a project's form is a few lines and duplicates as little of the
jail as possible. satan and doctrine then retire their copies (in W5,
CHR-023).
