# IMP-059: Form cargo and sccache caches do not persist across delegate runs

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

A quotient form's `~/.cargo` and `~/.cache/sccache` were absent or newly created
on each run in SL-023 PHASE-07 (inferred from two runs, 2026-11-04). sccache
therefore hits only within one run, each run re-fetches crates, and `cargo
--offline` fails. A Rust delegate pays a cold build every time.

Possible fix: bind a persisted cargo home and sccache dir into write forms,
weighed against the form's isolation (a shared cache is a shared write surface).
Confirm the cause first.
