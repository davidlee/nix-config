**Regressed 2026-10-17 (SL-010).** The CHR-008 settlement no longer holds. Any
root `nix flake lock` (and the evaluation commands `just drvs`, `just test`,
`just coverage`, `nix fmt`) re-resolves `emacs/emacs-overlay` to the latest
upstream rev, because the root lock's node (3d05567b at the time) no longer
matches `emacs/flake.lock`'s pin (b7d303d9). Observed three re-resolves in
one day (→ e87b60e7, → aa5307a6).

Before committing a lock change, keep emacs-overlay out of it: re-lock
from HEAD's lock, then restore HEAD's node, e.g.
`jq --slurpfile h head.lock '.nodes["emacs-overlay"] = $h[0].nodes["emacs-overlay"]'`.
Then compare every root input's rev against HEAD. The fix for the drift
itself is unknown: re-syncing the root node with `nix flake update emacs`
is the first thing to try.

The emacs input is fetched from GitHub, so a change to `emacs/flake.nix` that
must reach the lock needs a push, then `nix flake update emacs`. Until then
`tree_override` (read-only recipes) builds from the local checkout.

**treefmt cache.** `nix fmt` (treefmt: alejandra, statix, deadnix) caches by
mtime and once reported "0 changed" over 9 unformatted files. Use
`nix fmt --no-write-lock-file -- --no-cache` to really format the tree.
