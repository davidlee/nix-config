# SL-018 plan

Two phases, split on blast radius.

**PHASE-01** changes the library and its tests together, TDD: the tests
assert launcher text (bind flag, order), which is all the build sandbox can
observe — it has no user namespaces, so bwrap never runs. The env test and
`justfile` change ride along because the impure check is the only cover for
the env vars.

**PHASE-02** is everything that describes or consumes the library: README,
template, the Emacs devshell flake (a separate tree, `~/.config/emacs`), and
the hand-off to W5. It follows PHASE-01 so docs describe shipped behaviour.
Live `.envrc` consumers pick up PHASE-01's flip at their next direnv reload;
PHASE-02 should follow promptly so the Emacs devshell regains rw on notes.
