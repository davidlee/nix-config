# Review RV-048 — design of SL-024

Adversarial-review ledger. Structured findings live in the sister
ledger toml; this prose companion carries the reviewer's framing.

## Brief

Raiser: codex. Full adversarial design pass over SL-024's arrangement,
declaration samples, consumer wiring, failure modes and verification.

Governing context: SL-024's scope and non-goals; DEC-122 through DEC-127;
SPEC-003; POL-001; quotient:DEC-071 and quotient's policy/form contracts.
The operator's accepted choices (including host-bound profiles and the
form-probe stand-in) are constraints, not reopened design questions.

Lines of attack: evaluate the Nix samples with mock combinators; trace the
gateway wrapper, persisted-home/config mount ordering and subagent entrypoints;
compare every claimed spike result with the preserved scripts and diffs; check
whether the shipped consumer can repeat the required probes without the
spike's extra closure mounts. Distinguish source evidence and bounded probes
from actual agent login, build and runtime integration proof.

## Synthesis

Follow-up pass by codex: F-1, F-2 and F-3 are verified against the revised
artifacts and their underlying source evidence. F-1 now specifies the test-only
probe-closure fixture; F-2 distinguishes injected registration from client
discovery; F-3 limits the established MCP evidence to what the preserved probes
show. No new defect was found in the revisions.

These are completed prose repairs. The planned builds, fresh-jail probes,
registration smoke checks and logged-in delegate calls remain execution
obligations; this pass did not perform or certify them.
