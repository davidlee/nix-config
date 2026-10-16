# REV REV-007 — ADR-002 D1/D4/D5: platforms key; migration order proved by the gate

Revision — a pending revise-intent against authored governance/spec
truth. The structured `[[change]]` payload lives in the sister `revision-NNN.toml`;
this prose companion carries the rationale and the free-text before/after excerpts
for prose-body section edits.

## Rationale

<!-- Why this revision: what authored truth needs to change and why, the scope of
     the staged delta, and (for ADR/POL/STD/prose rows) the before/after excerpts
     the structured payload only labels. Seeded at `revision new`. -->

SL-008 (RFC-001 W5) has Draupnir import a `personal` profile, and the resolver's
only platform signal is the class set: `homeManager` spans Linux and darwin, so
a Linux-only home half selected on the Mac lands inert or fails inside Home
Manager (QUE-001). DEC-030 (user, 2026-10-16) answers it with a `platforms` key
on the record, which the resolver reads and enforces. DEC-035 (user,
2026-10-16) rewords D5 in the same revision, so governance matches the
gate-proven reorders SL-006 and SL-007 already accepted as slice-local
exceptions. Design: SL-008 `design.md` § Platform scope in the resolver,
§ Governance.

D1, before:

> A feature is plain data:
> `{ name; nixos?; homeManager?; darwin?; requires?; }`. … `requires` is an
> optional list of `"<area>.<name>"` prerequisites (ADR-001 D4). No other key
> is allowed: …

D1, after:

> A feature is plain data:
> `{ name; nixos?; homeManager?; darwin?; requires?; platforms?; }`. …
> `requires` is an optional list of `"<area>.<name>"` prerequisites (ADR-001
> D4). `platforms` is an optional list of system strings in nixpkgs
> `meta.platforms` style (`lib.platforms.linux`, `["x86_64-linux"]`); absent
> means every system (DEC-030). No other key is allowed: …

D4, before:

> … `requires` is a list of strings naming existing features; descriptor
> keys are known; … The resolver reads only key names, `name`, `requires`,
> option declarations and the position of `name`; …

D4, after:

> … `requires` is a list of strings naming existing features; `platforms`,
> where present, is a list of strings; descriptor keys are known; … The
> resolver reads only key names, `name`, `requires`, `platforms`, option
> declarations and the position of `name`; …

D5, before:

> Selected features project in list order (areas, then the features of
> each), never `attrNames` order. Migration preserves existing order. No
> numeric priorities without a concrete need.

D5, after:

> Selected features project in list order (areas, then the features of
> each), never `attrNames` order. A migration either preserves order or
> proves every reorder harmless with the drv gate (`mem.pattern.flakes.drv-gate`):
> every probe measure identical, or `nix-diff` shows list order only. A
> flipped collision winner stops the migration (DEC-035). No numeric
> priorities without a concrete need.

Also: the area list in D2 (`features/default.nix` lists the areas as written
`{ name; value; }` pairs) becomes "`features/default.nix` is a function of
`{lib}` mapping a written list of area names to `{ name; value; }` pairs";
records stay plain data. The Neutral consequence ("ordering-only diffs must be
proven with `drvs-sets` / `nix-diff`") stays and now cites D5.

Unchanged: D3, D6, D7. The exclusion boundary holds: `platforms` is a list of
strings on the record, never a class value.

Applied at SL-008 `/reconcile`, together with DEC-006's signature edit
(`+ system`) and the README Features section.
