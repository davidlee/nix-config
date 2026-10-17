# ISS-013: README crates.io removal command reads a transitive lock node, not the root nixpkgs input

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

README § crates.io "Removal" checks `.locks.nodes.nixpkgs.locked.rev`, a
transitive node; the root input is `nixpkgs_28` today. Correct form:
`.locks.nodes[.locks.nodes.root.inputs.nixpkgs].locked.rev`
(mem.fact.nix.lock-node-names). Found in SL-012 PHASE-05; RV-027 F-6.
