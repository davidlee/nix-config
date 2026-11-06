# REV REV-018 — SPEC-003: fleet repos that use Doctrine take capsule-tools; dev-envs warns

Revision — a pending revise-intent against authored governance/spec
truth. The structured `[[change]]` payload lives in the sister `revision-NNN.toml`;
this prose companion carries the rationale and the free-text before/after excerpts
for prose-body section edits.

## Rationale

<!-- Why this revision: what authored truth needs to change and why, the scope of
     the staged delta, and (for ADR/POL/STD/prose rows) the before/after excerpts
     the structured payload only labels. Seeded at `revision new`. -->

## Rationale

DEC-130 (2026-11-06) widens DEC-128: a fleet repo that uses Doctrine takes
`capsule-tools`, not only one whose room is judged to need it, and the default is
`dev-tools` plus Doctrine. REV-017 left enforcement out of scope until CHR-031;
that is done, and the operator chose a warning over a refusal. `doctrineWarning`
(`dev-envs/dev-env.nix`) runs at shell entry.

### SPEC-003

- § Producer contract, the `dev-tools` paragraph: "a project whose room needs
  Doctrine also exports `capsule-tools`, its tool list plus Doctrine, and its fleet
  target sets `toolsPackage = "capsule-tools"`." → "a fleet repo that uses Doctrine
  also exports `capsule-tools`, by default `dev-tools` plus Doctrine, and its fleet
  target sets `toolsPackage = "capsule-tools"` (DEC-130)."
- § Degrade and refuse, add a row: `dev-tools` holds `bin/doctrine`; the shell
  starts, with a warning naming DEC-128; caught by `checks.dev-env`.
- § Decisions, "Doctrine paths, PATH": add DEC-128, DEC-130.

Outside the spec, to the same wording: README § Jailed Agents and the comment in
`_templates/dev-env/flake.nix` (STD-001).
