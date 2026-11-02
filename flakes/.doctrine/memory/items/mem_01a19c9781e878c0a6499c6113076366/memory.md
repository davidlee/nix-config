The flakes worktree is `$HOME` (git dir `~/.git`), so committing is a broad `git add`. Commit `17991b29` ("abortive start on tangled; add smut", 2026-11-01) carried `flakes/features/session/snooze-nag` fully replaced by an unreviewed experimental variant — different design, never passing its behaviour test — while the test and README were untouched. That read as "HEAD behaviour, no local modification" and stalled ISS-022.

Applies to any file, especially scripts whose behaviour test is red while the test itself is green on a restored version.

Discriminating check, before accepting HEAD behaviour as intentional:

1. `git log --format='%h %ad %s' --date=short -3 -- <path>` — is the last commit's subject about this file?
2. `git log -S'<distinctive token>' -- <path>` — when did the suspect token (here `pactl`, `say -d`) enter? Same unrelated commit ⇒ swept in.
3. `git show <commit>^:<path>` and run the behaviour test against that version in a temp dir (`cp` test + old script beside each other; the test resolves its sibling by `$here`). If the restored version greens, the commit is the regression.

The daily driver does commit whole-file replacements of an experiment deliberately mid-thought; the commit message is not a reliable description of the diff.