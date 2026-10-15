Merged list options (`environment.systemPackages`, `sudo.extraRules`,
`extraGroups`, `nixpkgs.overlays`, …) concatenate in **reversed breadth-first**
order of the import tree: the closure is built breadth-first
(`genericClosure`) and merging prepends. Toy check: a imports [b c d], b
imports [e] → `[e d c b a]`.

Consequences:
- a module moved one level deeper (e.g. into a profile) moves **earlier** in
  every merged list;
- placing a profile "where the modules were" does not keep the drv gate exact;
- where order is semantic (overlays), state it with `mkBefore`/`mkAfter`.

Proving a diff is ordering-only: `just drvs-sets` (count + hash of sorted
package lists per config). Same sets but different drvs → ordering-only for
packages. Other lists (groups, sudo rules, firewall ports) need `nix-diff`
OLD.drv NEW.drv, then compare the differing drv's `env.__json`. Record each
accepted ordering diff with its new baseline. See [[mem.pattern.flakes.drv-gate]].
