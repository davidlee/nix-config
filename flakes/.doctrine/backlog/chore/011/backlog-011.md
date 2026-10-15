# CHR-011: Repoint ADR-001..003 MULTIHOST.md citations to RFC-001

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

MULTIHOST.md was retired in favour of RFC-001 (d2b787b5). ADR-001, ADR-002
and ADR-003 still cite it in their References: ADR-001 § References and
line 61 (lean defaults), ADR-002 lines 27 and 97 (Lessons), ADR-003 lines
14 and 53. The Lessons content is now in `mem.fact.nix.merge-order` and
`mem.pattern.flakes.drv-gate`. Repoint them by revision; there's no rush,
since git history still holds the file.
