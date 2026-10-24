# IMP-041: Workaround probes for non-nixpkgs flake inputs

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

The workaround registry (`workarounds/`, DEC-053, DEC-055) cannot track a
breakage in a non-nixpkgs flake input. Found with ISS-016 (`llm-agents`
chatgpt):

- `workarounds/probes.nix`: `pin` is an enum of `nixpkgs` | `nixpkgs-home`,
  and `attr` must resolve in that pin's package set, so even a
  `signal = "manual"` probe of `llm-agents.chatgpt` fails validation.
- `workarounds/check` asks only cache.nixos.org; `llm-agents` is cached by
  numtide (its own substituter).
- `workarounds/last-good` refuses an input not locked to github
  NixOS/nixpkgs, so there is no lastGood for such packages.

Shape to decide: a pin per input with its own package-set path and cache URL
(e.g. `llm-agents` → `packages.<system>` and numtide's cache), or a
`manual` probe that names a site without resolving an attr. Related: IMP-031
(shared evalModules schema helper with host-meta.nix).
