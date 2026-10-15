**Settled 2026-10-15 (CHR-008).** The old `emacs/emacs-overlay` re-lock is gone:
after `nix flake update emacs` (emacs → ee8d509c), `nix flake lock` and `nix fmt`
leave `flake.lock` byte-identical. The emacs input is fetched from GitHub, so
after any `emacs/flake.nix` change that must reach the lock: push, then
`nix flake update emacs`. Until then `home_override` builds from the local checkout.
Still check `git diff --stat flake.lock` before committing, out of habit.

**treefmt cache.** `nix fmt` (treefmt: alejandra, statix, deadnix) caches by
mtime and once reported "0 changed" over 9 unformatted files. Use
`nix fmt --no-write-lock-file -- --no-cache` to really format the tree.

**Checking, not formatting:** `just gate` = `just test` + the read-only
`checks.<system>.treefmt` flake check (sandboxed, uncached, no re-lock).
`doctrine check gate` runs it.

Also: `just -n` doesn't run backticks (prints `` `hostname` `` literally);
use `just --evaluate host`.
