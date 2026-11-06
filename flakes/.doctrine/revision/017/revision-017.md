# REV REV-017 — SPEC-003: Doctrine stays out of dev-tools; rooms take capsule-tools

Revision — a pending revise-intent against authored governance/spec
truth. The structured `[[change]]` payload lives in the sister `revision-NNN.toml`;
this prose companion carries the rationale and the free-text before/after excerpts
for prose-body section edits.

## Rationale

DEC-128 (2026-11-06) settles where Doctrine goes: `dev-tools` carries none, and
a room that needs it takes `capsule-tools`. DEC-112 made that split for Doctrine's
own flake only. SPEC-003 names neither `capsule-tools` nor the rule, so the
producer contract allows what DEC-128 forbids. The rule is new to the contract;
existing repos follow it through CHR-031.

### SPEC-003

- `sources:` add `nix _templates/dev-env/flake.nix`, the contract's worked example
  (STD-001).
- § Producer contract, after the `dev-tools` example, add:

  > `dev-tools` carries no Doctrine: dev-envs builds its shell, jails and forms
  > from it, and a jail's `extraPkgs` precede the host install on PATH, so a Nix
  > Doctrine there would shadow it. A room has no host binary, so a project whose
  > room needs Doctrine also exports `capsule-tools`, its tool list plus Doctrine,
  > and its fleet target sets `toolsPackage = "capsule-tools"`. The fleet target
  > changes before Doctrine leaves `dev-tools` (DEC-112's order). `dev-envs` does
  > not read `capsule-tools`.

- § Producer contract, "The project owes nothing else. It names no jail, agent,
  form or gateway." → "The project owes nothing else. It names no jail, agent,
  form or gateway. `_templates/dev-env` is the contract as a working flake."
- § Doctrine on both sides, first paragraph, add: "It is the only `doctrine` on
  PATH because `dev-tools` carries none."

Nothing enforces the rule yet: `checkDevEnv` reads `devEnv`, not the tool list. A
refusal in dev-envs is out of scope here, and would wait for CHR-031.
