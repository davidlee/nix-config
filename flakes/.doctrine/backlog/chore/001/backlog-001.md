# CHR-001: Retire modules/DESIGN.md into the composition tech spec

`modules/DESIGN.md` names `modules/home/nixos/` (actual: `modules/home/linux/`) and places code by evaluation class, which ADR-002 supersedes. Its configuration-style and update-semantics sections stay valid; fold them into the tech spec once the spike locks the structure.

## Scope note (2026-10-18)

This is the host-composition container in CHR-019's context spec: the
feature resolver (`features.nix`), the feature tree and profiles, hosts
(`hosts.nix`, meta/config/machine), the NixOS and home bases, and coverage
targets. ADR-001..005 are its architecture; the README § Features and
§ Hosts are its current prose. Consumers outside the repo: none directly,
but oubliette's fleet and the dev-checkout inputs enter through it.

## Resolution (2026-10-18)

SPEC-002 (Host composition, container, root until CHR-019) took over.
Its § Where config lives replaces DESIGN.md's checklist (now placed by
base / feature / machine / host, not by evaluation class); § Configuration
style and § Concerns (lifecycles and pins) fold in DESIGN.md's
configuration-style and update-semantics sections; the overlap rule is
kept as an unenforced convention. `modules/DESIGN.md` is deleted. README
§ Features and § Hosts trimmed to operations and link the spec.
ADR-003's reference now points at SPEC-002; DEC-034 amended (isolation strength, dev-checkout list).
Follow-up: IMP-039 (coverage completeness; `Sleipnir+speech` redundant).
