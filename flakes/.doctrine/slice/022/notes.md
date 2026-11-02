# SL-022 notes

## Review passes

**Pass 1 — RV-044 (design, human lane).** 2026-11-02. Ten sections attested at
revision 32; no findings raised. Scope re-read against DEC-099..DEC-106 and
updated in two places (the `justfile` row became the definite gate wiring, R6
gained the relative-path-node sharpening). Design-target selectors narrowed from
three scoping globs to the nine exact paths § Code impact commits to.

**No further pass before planning.** What remains uncertain is empirical rather
than argumentative, and each item is cheaper to settle by running one command in
phase 1 than by reading more prose:

1. that `quotientFormFamily`'s `packages` really is what a form's PATH is built
   from — asserted from `quotient/nix/form-family.nix`'s signature, never from a
   form that was built and inspected;
2. that `jail.nix` renders the project bundle into the launcher's text in one of
   the two forms `checks.stub` accepts (the bundle's path, or a flattened
   member's);
3. that a relative `path:` input locks relatively — verified during design by
   experiment; re-checkable in phase 1 by reading `dev-envs/flake.lock`.

A further adversarial pass is worth it only if phase 1 falsifies one of these —
and then the finding belongs on a new RV against the implementation, not on a
re-review of this design.

## Working notes

**Section order is not the section number.** The design run stores sections in
its own order and materialises them in that order: the rendered document runs
sec-1, sec-2, sec-3, sec-4, sec-5, sec-10, sec-6, sec-7, sec-8, sec-9 — i.e.
`sections` are numbered for the *reader's* sequence, not numerically. Re-declaring
a section does not move it. Never edit `design.md` by hand: it is materialised,
and the run compares its digest.

**A confined session changes how phases verify.** In this session `~/.cfg` (the
home repo's git dir) and `~/.cache` are read-only: `git add -N` and commits fail,
and a git-resolved flake ref cannot see a file the session just created. Phases
evaluate through `path:~/flakes/dev-envs#…` with `XDG_CACHE_HOME` redirected;
staging and committing belong to the operator or a non-confined session
(`mem.fact.flakes.confined-session-ro`). Builds work.

**Two facts established during design, with their evidence.** A relative `path:`
flake input is locked as `path = "./stub-project"`, not as an absolute path
(synthetic flake in `/tmp/lockprobe`). The dev-envs lock guard — reject `file:`
URLs and absolute path nodes — passes that relative node and fails an absolute
one (same synthetic lock, mutated). Both are re-runnable in a minute if a later
reader doubts them.

**`DEC-099` is superseded, not amended.** The first export contract put the form
linker in the dev shell; drafting found that a flake cannot read `../bin/…` from
its own store copy, so `DEC-106` replaces it and keeps the linker a repo script.
The pair is the record of why the first answer was wrong.
