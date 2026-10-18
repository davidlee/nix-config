# IMP-039: Check coverage completeness: every off feature has a target, no target is redundant

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

ADR-005 D1 asks that every off feature (selected by no host) has a
coverage target. Nothing checks it: targets in `hosts.nix` are kept by hand,
and `testOffFeatures` pins four of the five off features (not
`hardware.openrgb`). SPEC-002 § Concerns.

Found while authoring SPEC-002 (2026-10-18): the off set is exactly
`hardware.openrgb`, `virt.podman`, `ai.llama-cpp`, `ai.rocm`,
`services.sunshine`, all with targets. `coverage."Sleipnir+speech"` is now
redundant: Sleipnir selects `audio.speech` (commit `53c79623`).

Shape: a check (in `just test`, evaluation only) over (feature, class,
system) triples, not feature names: every half a record has is forced by
some host or target whose factory builds that class, on a system its
`platforms` allow. A `mkNixos` target covers only the nixos half (SPEC-002
§ Coverage and isolation, after the GPT review of 2026-10-18). Selected
features count too: a darwin half of a feature only Sleipnir selects is
uncovered. Then drop `Sleipnir+speech`.
