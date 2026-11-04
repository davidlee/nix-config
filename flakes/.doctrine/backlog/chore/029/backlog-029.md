# CHR-029: Bump dev-envs' agents pin once SL-023's commits are pushed

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

From RV-047 F-4 (SL-023 audit). `dev-envs` does not evaluate at its own lock:
agents is pinned at 27f6ca32, before PHASE-02, so `makeJailedAgent` refuses
`nixDoctrine`. Every entry point overrides agents, which hides it.

Gated on the operator pushing `main`: origin has PHASE-02's library, not
PHASE-07's (DEC-121). Then, in `dev-envs`, update the `agents` input only, and
run `just test` (its lock guard) plus a plain
`nix eval path:$HOME/flakes/dev-envs#packages.x86_64-linux.jailed-pi.name`.

Done when that eval succeeds with no override. IMP-060 needs the same pin.
