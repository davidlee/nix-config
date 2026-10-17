# REV REV-009 — ADR-004 D4: imported constants for fixed shared facts

Revision — a pending revise-intent against authored governance/spec
truth. The structured `[[change]]` payload lives in the sister `revision-NNN.toml`;
this prose companion carries the rationale and the free-text before/after excerpts
for prose-body section edits.

## Rationale

ADR-004 decision 4 says values shared by the system and home evaluations are
"typed options in the outer resolver" (`features.nix`). Practice has drifted
from that wording since SL-011:

- DEC-047 reads D4 as "constants or outer-resolver options".
- SL-011 `design.md:43` cites "ADR-004 D4: a constant, not a value read
  across evaluations" for `features/agents/gateway/constants.nix`.
- SL-013 DEC-059 moves those constants into the published `agents` sub-flake,
  so out-of-tree flakes (emacs, `~/dev/doctrine`, the template) import them.
  Those flakes never evaluate `features.nix`, so a typed outer option cannot
  reach them.

An imported constant keeps D4's aim (one source; no option read across
evaluations), so the ADR should name it. User chose to amend the ADR
(2026-10-17), not record a deviation. Found by a Codex second opinion on
SL-013; lands with SL-013's reconcile.

## Before / after (ADR-004 § Decision, Settings, item 4)

Before:

> 4. Values shared by system and home, or needed during composition, are typed
>    options in the outer resolver.

After (proposed):

> 4. Values shared by system and home, or needed during composition, are typed
>    options in the outer resolver. Fixed facts that are not tunables (an
>    address, a path), and values a consumer outside the flake also needs, may
>    instead be plain constants in one file that every consumer imports.

## Reconcile narrative

- [RV-030, SL-013 design sec-7]: landed by hand in ADR-004 § Decision,
  Settings, item 4, worded as the After excerpt above. SL-013 built the case:
  `agents/gateway.nix` is imported by the NixOS gateway, eca, the emacs and
  doctrine flakes and the template, none of which can read an outer option.
