# IMP-016: Settle the apps taxonomy; migrate apps.cad

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

Deferred from SL-005 (2026-10-15, user: "we can take a constrained definition
of apps for now, but if so should probably follow up").

"apps" is several concepts. Today they live in unflagged modules:

- graphics (krita, …): `modules/home/linux/graphics.nix`
- office: `modules/home/linux/office.nix`
- browsers / editors: `modules/home/linux/{browsers,editors,zed-editor}.nix`
- media, terminals: `modules/home/linux/{media,terminals}.nix`
- TUI / CLI apps: `modules/shared/cli/_packages/*.nix`
- CAD: `modules/home/linux/cad-3d.nix`, still behind the legacy `apps.cad` flag

SL-005 moved the app *formats* (appimage, flatpak) onto the tree and left
`apps.cad` as a legacy flag.

Decide which areas and features these become: one `apps` area, or several
areas by kind. Then migrate `apps.cad`. Do this alongside RFC-001 W5 (home
base / personal split), since most of these modules are home base or
personal. QUE-001 (platform scope) applies: they are Linux-only home halves.
