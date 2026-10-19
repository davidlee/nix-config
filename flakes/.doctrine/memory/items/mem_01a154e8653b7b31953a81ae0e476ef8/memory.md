For an eval-only check (`evalTests ./x-test.nix` in perSystem.nix, `lib.runTests` failures):

- The flake is a git flake (`.` on Linux), so a new test or data file is invisible until `git add -N`. Without it the check fails on a missing path, not on the behaviour under test.
- An absent or empty data file makes the test throw an eval error (`attribute 'x' missing`). That is red for the wrong reason, and it does not list failures.
- Red properly: a stub that has every key the tests read, with wrong values. Each test then reports `expected`/`result` in the `<file>.nix failed:` list.
- Mutation check before trusting green: add one stray key to the data and confirm that exactly the expected test fails.

Seen in SL-016 PHASE-02 (features/satan/room-test.nix).
