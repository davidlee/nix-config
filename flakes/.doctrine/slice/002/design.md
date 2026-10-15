<!-- doctrine:section sec-1 -->
## Overview

### What changes

Capsule (oubliette's agent capsule, host side) becomes the tree feature
`feature.virt.capsule`. It is NixOS-only and lives in one file that owns
every piece of it. Sleipnir selects it in its own `features.nix`.

```
before                                        after
hosts/Sleipnir/config.nix                     hosts/Sleipnir/features.nix
  imports modules/nixos/capsule.nix             feature.virt.capsule.enable = true
modules/nixos/network.nix                              │ resolver projects
  vm-capsule port 3128                                 ▼
  nftables table capsule-forward              features/virt/capsule.nix
modules/nixos/security.nix                      microvm host + capsule-perimeter
  sudo: nft list table inet capsule-forward     vm-capsule port 3128
modules/nixos/user.nix                          nftables table capsule-forward
  users.users.assigner                          sudo: nft list … capsule-forward
                                                users.users.assigner
                                                nftables.enable = true
```

### Why

RFC-001 W1. Capsule is the second migration onto the tree, and the first
whose pieces live in shared base modules. Making the feature own them means
a future host without capsule (RFC-001: nixosvm, a work Mac guest) carries
none of its perimeter.

### The boundary

- Ownership move only. Capsule's behaviour on Sleipnir does not change, and
  the derivations stay identical or differ by order only (sec-4).
- Every piece sets an upstream NixOS option, which ADR-004 D1 allows. No
  piece depends on another feature's selection, so ADR-004 D2–D3 (the
  composition slot) is not exercised (inq-7).
- Out of scope: legacy flags (W3), agents (W2), IMP-003, ISS-003, the
  oubliette input.

<!-- doctrine:section sec-2 -->
## Feature, index and selection

DEC-010, DEC-011.

### Index files

```nix
# features/default.nix — virt appended after session
[
  { name = "hardware"; value = import ./hardware; }
  { name = "session";  value = import ./session; }
  { name = "virt";     value = import ./virt; }
]

# features/virt/default.nix — new
# Virtualisation features, in projection order.
[
  { name = "capsule"; value = {nixos = ./capsule.nix;}; }
]
```

The position does not matter here. No other projected feature sets sudo,
firewall, nftables or users. Snooze's NixOS half sets none of them
(research, DEC-010).

### The feature file

`features/virt/capsule.nix` takes the whole of `modules/nixos/capsule.nix`
(the header comment, the imports and `services.capsule-perimeter`),
followed by the pieces from sec-3, grouped by concern:

```nix
{inputs, username, ...}: {
  imports = [ …microvm host…  …capsule-perimeter… ];   # as today

  microvm.host.enable = true;
  services.capsule-perimeter = { enable = true; owner = username; };

  # Devshell path (tap in the root namespace): its perimeter.
  networking = {
    nftables.enable = true;   # also set host-wide in network.nix
    firewall.interfaces."vm-capsule".allowedTCPPorts = [3128];
    nftables.tables.capsule-forward = { … };   # unchanged text
  };
  security.sudo.extraRules = [ { users = [username]; commands = [ …nft list… ]; } ];

  # Unprivileged user for oubliette.
  users.users.assigner.isNormalUser = true;
}
```

The rule text, table content and port are copied verbatim. Only the
comments change: references to "network.nix" and "security.nix" now point
within this file (sec-3).

### Selection

```nix
# hosts/Sleipnir/features.nix
feature.virt.capsule.enable = true;
```

This is a plain definition, not a profile. Capsule needs KVM and the local
oubliette checkout, so it is a property of the host (DEC-011). The darwin
host cannot select it: the resolver's D6 check rejects a NixOS-only feature
there.

<!-- doctrine:section sec-3 -->
## What leaves the base modules

DEC-012.

| from | piece | to |
|---|---|---|
| `modules/nixos/capsule.nix` | whole file | `features/virt/capsule.nix`; source deleted (`git mv`, so history follows) |
| `modules/nixos/network.nix` | `firewall.interfaces."vm-capsule"` and its comment | feature |
| `modules/nixos/network.nix` | `nftables.tables.capsule-forward` and its comment | feature |
| `modules/nixos/network.nix` | `nftables.enable = true` | **stays**: it selects the firewall backend for the whole host |
| `modules/nixos/security.nix` | the `nft list table inet capsule-forward` rule and its comment | feature |
| `modules/nixos/user.nix` | `users.users.assigner` | feature |
| `hosts/Sleipnir/config.nix` | `../../modules/nixos/capsule.nix` import | removed |

What remains in each base module is unchanged, except that `security.nix`
drops its `username` argument. The nft rule was its only use (`:40`), and
deadnix would flag it. `security.nix` keeps its `ORDER IS SIGNIFICANT`
comment and the rtcwake rule.

### Comments

These comments point at each other across files today. After the move they
become references within one file:

- capsule.nix header, lines 16–20: "network.nix's FORWARD drop … plus
  security.nix's … sudo rule" → "the FORWARD drop … and the sudo rule
  below".
- network.nix lines 67–69: "see the sudo read rule in security.nix" →
  "below".
- security.nix lines 29–31: "the FORWARD drop on the tap (network.nix)" →
  "(above)".
- `flake.nix:113`: "wired in modules/nixos/capsule.nix" →
  `features/virt/capsule.nix`.
- `SATAN.md:24`: the host-module column → `features/virt/capsule.nix`.
- Outside this repo, `~/dev/oubliette/README.md:242` names the old path.
  That is a follow-up for oubliette, not part of this slice.

The `features/virt/capsule.nix` header says that the devshell-path pieces
serve only that path. The unit path installs its own perimeter
(oubliette `host/netns.nix`).

<!-- doctrine:section sec-4 -->
## Merge order

DEC-013. Research cross-thread findings 1 and 2.

The feature module sits at the same import depth as `security.nix` today:
a projected module is `{ _file; imports = [descriptor.nixos]; }`, appended
after `hosts/<h>/config.nix` (`hosts.nix:70-76`). Merged lists may still
reorder (`mem.fact.nix.merge-order`).

| option | kind | effect of the move |
|---|---|---|
| `security.sudo.extraRules` | list, last-match-wins | The nft rule may move relative to the rtcwake rule. Safe: the commands are disjoint. The blanket root and `%wheel ALL` rules are at `mkOrder 400` and `mkOrder 600` (nixpkgs `sudo.nix:252,257`), both before the default 1000, and stay first. Oubliette's proxy-restart rules are `mkAfter` and stay last. |
| `networking.firewall.interfaces` | attrset, keyed by interface | none: only capsule sets `vm-capsule` |
| `networking.nftables.tables` | attrset, keyed by table | none |
| `networking.nftables.enable` | bool, set `true` twice (plus oubliette's `mkDefault true`) | none |
| `users.users` | attrset, keyed by user | none |

No `mkBefore` or `mkAfter`. If the rendered sudoers changes, the accepted
form is exactly the five rule lines in research Thread 2 with lines 3 and 4
swapped, and nothing else.

<!-- doctrine:section sec-5 -->
## Verification

DEC-014.

### Test (red, then green)

One test in `features-test.nix` on the real tree, checking membership in
the existing style:

```nix
# Real tree, Sleipnir's own selection: capsule is projected, NixOS only.
testSleipnirSelectsCapsule = {
  expr = let
    r = resolve {
      tree = real;
      classes = both;
      modules = [./hosts/Sleipnir/features.nix];
    };
  in [
    (lib.elem "features/virt/capsule#nixos" (tags r.modules.nixos))
    (lib.any (lib.hasPrefix "features/virt/capsule") (tags r.modules.homeManager))
  ];
  expected = [true false];
};
```

- **Red** before the change: `[false false]`, an ordinary assertion
  failure. (Land the tree entry before the selection line. The reverse
  order makes an eval error that aborts the whole `features` check.)
- It tests Sleipnir's selection on purpose: the suite goes red if
  Sleipnir stops selecting capsule. The class boundary (no darwin module)
  is the resolver's generic D6 check, already tested in SL-001.
- **Green** once the tree entry and the selection land.
- Mutation check, reverted afterwards: drop the selection line and the
  test turns red.

### The gate

1. Snapshot `just drvs` and `just drvs-sets` before editing
   (`mem.pattern.flakes.drv-gate`), and render Sleipnir's sudoers (the
   `nix eval … security.sudo.configFile` from research).
2. After the change, every configuration's drvPath is identical. If
   Sleipnir differs, `drvs-sets` must match, and the sudoers diff must be
   exactly the swap allowed in sec-4. Anything else is a red gate.

### Negative control (one-off, not committed)

Set `feature.virt.capsule.enable = false` in Sleipnir's `features.nix`,
then evaluate:

- sudoers has no `capsule-forward` line;
- `networking.firewall.interfaces` has no `vm-capsule`;
- `networking.nftables.tables` has no `capsule-forward`;
- `users.users` has no `assigner`;
- `services.capsule-perimeter` is undefined, because the option module is
  not imported.

Record the results in the slice notes, then revert. This proves the off
case once, without a coverage target, which ADR-005 does not require while
Sleipnir selects capsule.

### Hygiene

`just test` is green, and `nix fmt` is clean (statix and alejandra) without
committing the emacs-overlay re-lock (`mem.fact.flakes.fmt-relock`). New
files are `git add -N`'d before any evaluation.

<!-- doctrine:section sec-6 -->
## Code impact

| path | change |
|---|---|
| `features/virt/capsule.nix` | moved from `modules/nixos/capsule.nix` (`git mv`); gains the network, sudo and user pieces; comments rewritten |
| `features/virt/default.nix` | new. Area index: `capsule` |
| `features/default.nix` | append `virt` |
| `modules/nixos/network.nix` | drop the `vm-capsule` firewall entry and the `capsule-forward` table, with their comments |
| `modules/nixos/security.nix` | drop the nft read rule and its comment, and the now-unused `username` argument |
| `modules/nixos/user.nix` | drop `users.users.assigner` |
| `hosts/Sleipnir/config.nix` | drop the `capsule.nix` import |
| `hosts/Sleipnir/features.nix` | `feature.virt.capsule.enable = true` |
| `features-test.nix` | `testSleipnirSelectsCapsule` |
| `flake.nix` | the oubliette input's comment: new path |
| `README.md` | Feature tree: areas list and layout gain `virt/capsule.nix` |
| `SATAN.md` | the oubliette row's host-module path |

Unchanged: `features.nix`, `hosts.nix`, `modules/features.nix`, `darwin/**`,
the justfile, and every other module.

Follow-up, outside the repo: `~/dev/oubliette/README.md:242` (old path).

Out of scope, kept as is: the oubliette input and `system_override`
(ISS-003), and the `extraGroups` list (IMP-003).

