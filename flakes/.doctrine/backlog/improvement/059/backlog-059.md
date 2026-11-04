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

## Resolution (2026-11-04)

By design. A quotient form's home is disposable; a pi jail's persisted home is
not. They are different classes with different tradeoffs, and a delegate run
paying a cold build is the consequence of the first. A shared cache would also
be a shared write surface across runs. No change. If cold builds become a real
cost, reopen with a per-project cache for write forms.
