# CHR-015: Draupnir link-map check at the next home-switch (SL-008 VH-2)

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

SL-008 PHASE-07 VH-2, deferred by the user to the next Draupnir home-switch
(RV-018). Draupnir cannot be built from Sleipnir, so its home has no probe;
P7 added ~55 packages there (availability filter, DEC-036).

Before activating the new home on Draupnir, run `bin/gate-probe` against
`homeConfigurations."david@Draupnir"` and diff its `home-path-links` with the
current generation's `home-path` (exact commands: SL-008 notes.md § PHASE-07
"Pending user", VH-2). Look for a `bin/X` whose target package name changes
(a flipped collision winner) — especially `binutils-wrapper` vs cctools
(`ld ar as nm strip ranlib size strings objdump`), and BSD vs GNU tools from
`procs`, `htop`. A flip is fixed forward with hiPrio/lowPrio or brokenOn.
