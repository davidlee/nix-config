**Settled 2026-10-15 (CHR-008).** The old `emacs/emacs-overlay` re-lock is gone:
after `nix flake update emacs` (emacs → ee8d509c), `nix flake lock` and `nix fmt`
leave `flake.lock` byte-identical. The emacs input is fetched from GitHub, so
after any `emacs/flake.nix` change that must reach the lock: push, then
`nix flake update emacs`. Until then `tree_override` (read-only recipes) builds from the local checkout.
Still check `git diff --stat flake.lock` before committing, out of habit.

**treefmt cache.** `nix fmt` (treefmt: alejandra, statix, deadnix) caches by
mtime and once reported "0 changed" over 9 unformatted files. Use
`nix fmt --no-write-lock-file -- --no-cache` to really format the tree.

**Checking, not formatting:** `just gate` = `just test` + the read-only
`checks.<system>.treefmt` flake check (sandboxed, uncached, no re-lock).
`doctrine check gate` runs it.

Also: `just -n` doesn't run backticks (prints `` `hostname` `` literally);
use `just --evaluate host`.

**Correction 2026-10-16 (ISS-010).** The "byte-identical" result above held
only while emacs-overlay's upstream HEAD equalled the locked rev. Because
flake.nix overrides `emacs/emacs-overlay` with an unpinned URL, every lock
write (`nix flake lock`, `nix flake update <any input>`, `nix fmt`) re-resolves
it once upstream moves. After a deliberate `nix flake update X`, check
`git diff flake.lock` for an emacs-overlay bump; to keep it out, pin it back:
`nix flake lock --override-input emacs/emacs-overlay github:nix-community/emacs-overlay/<old rev>`.
