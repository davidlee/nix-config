# ISS-012: Audit shell tests for inert negated assertions (bash errexit ignores ! cmd)

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

`set -e` (errexit) does not fire on a negated command, so a bare `! grep …`
assertion can never fail a test. SL-011 PHASE-04 found every such assertion in
`agents/jailed-agents-test.nix` inert, including the provider-key argv-safety
check, and fixed it there with a `refute` helper (RV-026 F-14). Sweep the
other shell tests (feature `*-test` scripts, Nix check scripts, justfile
recipes) for the same pattern; convert to `refute` / `if …; then exit 1; fi`.
Check each conversion by mutation: the test must fail when the guarded
condition is broken.

## Resolution (2026-10-19)

Sweep found no remaining bare `! cmd` assertions: SL-011 had converted all of
them, and every other shell test asserts with `check <expected> <actual>`.
Every script in scope runs under errexit except `git-guard.test.sh`, which
counts its failures. Two latent `test -n a && test -n b && test b -gt a`
chains in `agents/jailed-agents-test.nix` (non-final `&&` parts escape
errexit; masked by the pipefail assignments above them) were split into
three lines. `refute` stays local: nothing else needs it. The near-identical
`check()` in five test scripts is a separate possible tidy-up.
