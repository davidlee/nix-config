# IMP-053: Improve feature layout and area boundaries

Make the feature tree easier to navigate and give overlapping areas clearer ownership:

1. Split the larger independently selectable records in `features/audio.nix` into feature files under `features/audio/`, alongside their assets; retain an explicit ordered area index.
2. Clarify the distinction between the desktop `shell` area and command shells in `terminal`, potentially by renaming the area to `desktop-shell`.
3. Define and apply boundaries for `ai`, `agents`, and `satan`: keep SATAN-specific integration cohesive and make the placement of model infrastructure and AI clients, including Claude Desktop and ChatGPT, predictable.

Treat the names and exact boundaries as design choices. Renaming an area changes feature paths and their references; preserve projection order and verify any changes to module merge behavior in accordance with ADR-002.
