Three distinct things, often conflated:

| Concept | Owner |
|---|---|
| Installed sessions | selected compositor features |
| Default session | host-level outer setting, asserted to be selected; feeds the greeter |
| Current session identity (`XDG_CURRENT_DESKTOP`, `XDG_SESSION_DESKTOP`) | the launched session — never a global variable |

Graphical login (the greeter) is its own capability, normally selected by a
desktop profile; a compositor does not imply it (it can run from a TTY).

Portal configuration is keyed by **portal desktop identifiers** (the value of
`XDG_CURRENT_DESKTOP` the session sets), not by our feature names. Verify the
identifier per compositor before encoding a mapping.

Counter-example in the repo: `modules/nixos/wayland.nix` sets both variables
to `niri` system-wide, which is wrong under umbriel (the session in use).
