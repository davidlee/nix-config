Refactors must not change what any host builds. Compare drvPaths
(evaluation only):

```bash
just drvs 2>/dev/null > ~/.cache/multihost-gate/before   # BEFORE editing
# … edit; git add -N new files …
just drvs 2>/dev/null > ~/.cache/multihost-gate/after
diff ~/.cache/multihost-gate/{before,after}
```

- Baseline = the tree as found, user's uncommitted edits included (no
  checkout needed). Take before/after close together.
- A diff is red unless expected; ordering-only diffs need proof
  ([[mem.fact.nix.merge-order]]).
- `drvs` takes 35–60 s; run it in the background while reading code.
- `drvs` pins repo-varying values (agents registry path, darwin
  `configurationRevision`). A new reference to `inputs.self` / `self.rev`
  makes the gate noisy: pin it in `drvs` too.
- The user commits concurrently. If a non-target config moves, check
  `git log` / mtimes first. With `--override-input emacs path:…`, the nested
  emacs-overlay re-resolves to the newest GitHub rev on each eval, so
  home/darwin can drift over hours with no local change.
- aarch64 hosts: eval only. Darwin evaluates from Linux.
