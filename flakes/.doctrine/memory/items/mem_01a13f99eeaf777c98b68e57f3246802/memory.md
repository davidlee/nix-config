NixOS builds `/run/current-system/sw` with `buildEnv` and `ignoreCollisions`.
When two packages ship the same path, the **first** in `environment.systemPackages`
keeps it (`pkgs/build-support/buildenv/builder.pl:200-202`, the ignored branch
returns and keeps the old target). `meta.priority` (`lib.hiPrio` / `lib.lowPrio`)
overrides position.

Consequence for the drv gate (`mem.pattern.flakes.drv-gate`): an "order-only"
`systemPackages` diff is **not** proven harmless by an identical sorted set.
Moving a module (e.g. into a tree feature, appended after the host's imports)
moves its list entries and can flip a collision winner.

Live case (SL-005, RV-011 F-8): podman `dockerCompat` ships `bin/docker`;
real docker won only because `docker.nix`'s entry came first.

How to prove: build `config.system.path` before and after and compare
`find -type l -printf '%P -> %l\n' | sort`. How to pin: `lib.hiPrio` /
`lib.lowPrio` on the package that must win.
