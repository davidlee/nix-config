# Capsule onto the feature tree

## Context

RFC-001 W1, and the second migration onto the feature tree after SL-001
(snooze, openrgb).

Capsule is oubliette's agent capsule. Its host side is spread across four
files and imported unconditionally on Sleipnir:

| piece | where |
|---|---|
| microvm host + `capsule-perimeter` modules, `services.capsule-perimeter` | `modules/nixos/capsule.nix` (imported at `hosts/Sleipnir/config.nix`) |
| `vm-capsule` interface-scoped port 3128; `capsule-forward` nftables table (FORWARD drop on the tap) | `modules/nixos/network.nix` |
| read-only `nft list table inet capsule-forward` NOPASSWD rule | `modules/nixos/security.nix` (`sudo.extraRules`) |
| `assigner` unprivileged user | `modules/nixos/user.nix` |

The pieces outside `capsule.nix` serve the devshell path
(`capsule-net up && capsule-host`), whose tap lives in the root namespace.
They set upstream options (firewall, nftables, sudo, users) that exist in
every NixOS evaluation. ADR-004 D1 allows that directly. So this is an
ownership move, not a selection-dependent integration, unless research
finds a piece that is.

## Scope & Objectives

1. One feature, `feature.virt.capsule` (`features/virt/capsule.nix`),
   NixOS half only. It owns all four pieces: `capsule.nix`'s content, the firewall port, the nftables table,
   the sudo rule and the `assigner` user. Comments travel with them.
2. `network.nix`, `security.nix` and `user.nix` lose the capsule pieces.
   `hosts/Sleipnir/config.nix` loses the `capsule.nix` import.
3. Sleipnir selects it in its own `features.nix`.
4. Gate:
   - `just drvs` is identical for every configuration, or the diff is
     ordering-only and proven with `drvs-sets` / `nix-diff`.
   - The sudo rule order is checked semantically: sudoers is
     last-match-wins (`security.nix` comment).
5. Verification (DEC-014):
   - `testSleipnirSelectsCapsule`: on the real tree with Sleipnir's
     `features.nix`, capsule projects its NixOS half and nothing else.
   - The off case is proven once by a negative control (selection removed,
     capsule pieces absent), recorded in notes and not committed. There is
     no `flake.coverage` target: ADR-005 doesn't require one while
     Sleipnir selects capsule.
6. README: feature tree description and any area added.

## Non-Goals

- The legacy flags in general (W3), agents (W2), and IMP-003's group list.
  Capsule has no group in `user.nix`; the central `extraGroups` list stays.
- ISS-003: `system_override` still fetches `~/dev/oubliette` eagerly. The
  feature being off does not fix that, because overrides are resolved
  before evaluation.
- The `oubliette` flake input itself, and anything oubliette-side.
- QUE-001 (platform scope), unless design finds capsule forces it. A
  NixOS-only feature already cannot be selected on darwin (ADR-005 D6
  check).
- Changing capsule's behaviour.

## Summary

Move the capsule's host side into one tree feature that owns every piece
of it, selected on Sleipnir, with identical derivations.

### Risks

- **sudo rule order**, resolved by DEC-013. nixpkgs' blanket rules are at
  `mkOrder 400` and stay first. The nft rule and the rtcwake rule are
  disjoint, so a swap between them is ordering-only. No `mkAfter`.
- **nftables dependency**, resolved by DEC-012. `nftables.enable` stays
  in `network.nix` (it is host-wide), and the feature sets it too.

### Decisions

DEC-010 (area `virt`, single file), DEC-011 (Sleipnir's `features.nix`
selects it), DEC-012 (ownership), DEC-013 (sudo order), DEC-014
(verification). Research: `research/research.md` (runtime).

### Not exercised

ADR-004 D2–D3 (the composition slot). Nothing here depends on another
feature's selection, so HYP-001's open point stays with RFC-001 W2/W3.

## Follow-Ups

- W2 agents, W3 legacy flags (RFC-001).
