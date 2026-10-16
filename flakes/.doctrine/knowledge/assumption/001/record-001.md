SL-007 PHASE-05 adds `coverage."base@aarch64-linux"`. `just coverage` evaluates
its toplevel drvPath on the x86_64 workstation, which forces every package's
platform check. We assume this is enough evidence that the NixOS base suits a
headless aarch64 host (RFC-001 W4). Building or booting it is W7's job.

Breaks if: a base package evaluates on aarch64 but fails to build or run there.
