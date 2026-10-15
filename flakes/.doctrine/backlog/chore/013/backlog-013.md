# CHR-013: Refresh stale dictate.nix references in the dictate script and umbriel binds

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

SL-006 moved `modules/home/linux/dictate.nix` into the `dictate` record of
`features/audio.nix` (RV-014 F-4). Two comments still name the old file:

- `features/audio/dictate:19` — "set by dictate.nix". Editing the script
  moves its store path, so SL-006's set-preserving gates forbade it; do it
  as its own commit and accept that one drv change.
- `~/.config/umbriel/binds.toml:45` — outside `flakes/`.
