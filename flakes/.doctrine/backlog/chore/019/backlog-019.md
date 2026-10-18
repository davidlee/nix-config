# CHR-019: Author a context spec: this repo as an integration hub

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

The repo is where several others meet, and nothing describes that whole.
A C4 context spec would name the containers and the edges between repos,
and nothing more: each container's mechanism stays in its own spec.

```
inbound (flake inputs)                     outbound (consumed elsewhere)
  oubliette mkFleet + fleet ──┐        ┌──> agents/ jail library   (~/dev/* flakes, doctrine, template)
  goad, panopticon          ──┤        ├──> LLM gateway, SPEC-001  (jails, gptel/minuet, satan, oubliette rooms)
  satan-patcher, satan-attrd──┼─ hosts ┼──> emacs/ flake           (~/.config/emacs, satan devshells)
  emacs-overlay, nixpkgs    ──┘        └──> templates (agents, lang)
```

Containers: host composition (features, profiles, hosts; CHR-001), the
agents jail library (CHR-020), the LLM gateway (SPEC-001), the emacs flake,
workarounds. Cross-cutting: the dev-checkout override (`bin/dev-checkouts`,
DEC-037, DEC-038), lock policy, POL-001.

Gives SPEC-001 and later container specs a parent. Write it thin, after or
alongside CHR-001, so it names real containers rather than planned ones.
Related: IDE-008 (which containers might leave), ISS-011 (an oubliette
follows edge already broke).
