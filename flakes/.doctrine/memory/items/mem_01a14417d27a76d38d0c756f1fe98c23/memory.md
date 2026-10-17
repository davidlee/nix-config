`lib.meta.availableOn platform pkg` reads only `pkg`'s own `meta.platforms` / `badPlatforms`. It does not see:
- a dependency unavailable on the platform (gtt→alsa-lib, udiskie→libappindicator-gtk3, micro-with-wl-clipboard→wayland fail to *evaluate* on aarch64-darwin);
- `meta.broken` (fsearch);
- a package missing from cache.nixos.org (shell_cmds/killall, yEd on darwin);
- an equal-priority buildEnv collision (binutils-wrapper vs gcc-wrapper on darwin: bin/strings, ar, nm, strip…).

Those go in `features/platform-skips.nix`, keyed by system, compared with `lib.getName` — which gives the **pname** (`micro`, `shell_cmds` for killall, `binutils-wrapper`), not the attr name. DEC-036 owns the rule. Pre-check collisions without building: `nix store ls --store https://cache.nixos.org <out>/bin` for every home package, then compare duplicate names against `meta.priority` (lower wins; only equal priority fails the build).

