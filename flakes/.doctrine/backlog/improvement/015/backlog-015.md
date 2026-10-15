# IMP-015: just test/gate use '.#' so the gate cannot run on the Mac

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

From SL-004 PHASE-05 (scope kept to the design): the justfile's `flake`
variable (`path:<justfile dir>` on macOS, `.` elsewhere) is used by the home,
darwin and `_drvs` recipes, but `test` and `gate` still build
`.#checks.…`. On the Mac `.` hits the bare `~/.git` discovery failure, so
`just gate` (and `doctrine check gate`) cannot run there.

Fix: use `{{flake}}#checks.…` in both. Linux unchanged (`.`).
