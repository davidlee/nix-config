# DEC-036: cli packages filtered by availability, with an explicit broken list

<!-- Knowledge record body — context, detail, links. The structured, queried
     fields live in the sister `record-NNN.toml`; this prose is free-form and is
     never structurally parsed (the storage rule). -->

Choice generalised at SL-008 `/reconcile` (RV-018 F-6, F-15). The delivered aarch64-darwin list has nine names: watchman (build fails), atuin (uncached, ISS-007), gtt, udiskie, micro (fail to evaluate through dependencies), fsearch (`meta.broken`, which availableOn ignores), shell_cmds and yEd (uncached; skipped by the user's PHASE-07 VH-1 choice), binutils-wrapper (collides with gcc-wrapper at equal priority on bin/strings, ar, nm …; found at PHASE-07 VH-2, 773f7dc9). Reasons live beside the list in `features/cli-broken.nix`.