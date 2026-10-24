# ISS-017: v4l2loopback 0.15.4 ships depmod index files on kernel 7.3: modules tree conflicts

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

Found 2026-10-24 on Sleipnir, after a lock bump moved the kernel to 7.3
(`linuxPackages_latest`). `linux-7.3-modules` (the `buildEnv` behind
`boot.extraModulePackages`) fails: `v4l2loopback-0.15.4/lib/modules/7.3.0/`
now holds depmod's index (`modules.dep`, `modules.alias`, …), which collides
with the kernel's. The nixpkgs recipe deletes `depmod` from the module's
Makefile; the kernel's own `modules_install` evidently still runs it on 7.3.

Workaround, one site: `features/desktop/core/v4l2loopback.nix` overrides the
package to delete `$out/lib/modules/*/modules.*` after install. Probe
`linuxPackages_latest.v4l2loopback` in `workarounds/default.nix`, manual: the
broken package is cached, so the cache cannot signal the fix.

Done when: the unpatched `v4l2loopback.out` has no `lib/modules/*/modules.*`
(`ls $(nix build --print-out-paths --no-link nixpkgs#linuxPackages_latest.v4l2loopback.out)/lib/modules/*`),
the override and probe are removed, and `just system-build` succeeds.
Upstream fix candidate: `DEPMOD=true` in the recipe's `makeFlags`.
