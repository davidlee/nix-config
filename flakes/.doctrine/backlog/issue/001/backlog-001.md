# ISS-001: Session identity hard-coded to niri

`modules/nixos/wayland.nix` sets `XDG_CURRENT_DESKTOP` and `XDG_SESSION_DESKTOP` to `niri` system-wide, and `greeter.nix` defaults the session to `niri`. Confirmed wrong under umbriel, the session in use: portal lookup reads niri's section.

Fix per CPT-001: identity comes from the launched session; the default session is a host-level value asserted to be selected. A behaviour change — its own slice, never inside an identity-preserving migration.
