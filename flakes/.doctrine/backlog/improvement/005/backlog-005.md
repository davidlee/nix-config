# IMP-005: Portal preference fan-out via a list option

`modules/nixos/xdg.nix` writes the FileChooser=kde preference into every desktop's portal section (portal config is first-file-wins per desktop) over a hard-coded list `[common kde niri sway mango umbriel]`, and installs the KDE portal unconditionally. Per ADR-004 (integration through an always-present option): the base desktop declares a list of portal desktop identifiers; each compositor appends its identifier; the base maps the preference over it. Verify identifiers per compositor first (CPT-001).
