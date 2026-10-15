# ISS-008: niri home half carries umbriel's tray and wallpaper

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

`modules/home/linux/niri.nix` (SL-006: moves verbatim into the `desktop.niri`
feature) also enables `services.tailscale-systray` and the `swaybg` wallpaper
user service. Both run under umbriel, the session in use, so deselecting
`desktop.niri` would silently drop them from umbriel. Move them to their real
owner (umbriel, or the home base) once RFC-001 W4/W5 classify the desktop
base. Found during SL-006 design (inq-4).

Related (RV-013 F-9): `modules/home/linux/sleipnir-doctor.nix:1` runs python
from the sway home half's `wpmPython` env — another implicit runtime
dependency on `desktop.sway`.
