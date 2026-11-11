# ISS-028: nixpkgs cargoSetupHook system-lib mode breaks Rust recipes relying on vendored C deps

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

Found 2026-11-10 on Sleipnir, after a lock bump moved nixpkgs to `f4a03c0`
(static-web-server 2.44.1). The build fails in `zstd-sys`'s build script
("The pkg-config command could not be found"); with pkg-config and zstd
added, `libgit2-sys` fails next (`LIBGIT2_NO_VENDOR` set by nixpkgs' Rust
tooling, no system libgit2). The recipe declares no `nativeBuildInputs` or
`buildInputs`.

Workaround, one site: `features/services.nix` (webserver feature) overlays
`static-web-server` with `nativeBuildInputs += pkg-config` and
`buildInputs += zstd libgit2`. An overlay, because
`services.static-web-server` has no `package` option. Probe
`static-web-server` in `workarounds/default.nix`: the unpatched package
appearing on cache.nixos.org signals the upstream fix.

Done when: `workarounds/check nixpkgs` reports the probe as a removal
candidate, the overlay and probe are removed, and `just system-build`
succeeds.

## Cause (2026-11-10)

Not a per-recipe bug. This nixpkgs' `cargoSetupHook`
(`pkgs/build-support/rust/hooks/cargo-setup-hook.sh`) exports
`ZSTD_SYS_USE_PKG_CONFIG`, `LIBGIT2_NO_VENDOR`, `RUSTONIG_SYSTEM_LIBONIG`,
`LIBSSH2_SYS_USE_PKG_CONFIG`, `SODIUM_USE_PKG_CONFIG` and others, so `-sys`
crates must find system libraries via pkg-config. Recipes that relied on the
vendored C sources fail until upstream adds the inputs. Expect more.

Fix at every site: `overrideAttrs {dontCargoUseSystemLibs = true;}`, the
hook's own opt-out, which restores the vendored C sources. Chosen over adding
`pkg-config` + the library to each recipe: uniform, needs no per-library
knowledge, and the only option for felix, whose `libgit2-sys 0.17` requires
libgit2 `< 1.9` while nixpkgs ships 1.9.7. (The first two sites briefly used
the inputs approach; both verified building with the opt-out instead.)

| package | pin | crate(s) | site |
|---|---|---|---|
| static-web-server 2.44.1 | nixpkgs | zstd-sys, libgit2-sys | `features/services.nix` (overlay; module has no `package` option) |
| xq 0.5.0 | nixpkgs-home | onig_sys | `features/data.nix` |
| felix-fm 2.16.1 | nixpkgs-home | libgit2-sys 0.17 | `features/files.nix` |
| oha 1.16.0 | nixpkgs-home | aws-lc-sys | `features/net.nix` |
| viddy | nixpkgs-home | libsqlite3-sys | `features/dev.nix` |
| tui-journal | nixpkgs-home | libsqlite3-sys | `features/notes.nix` |
| leaf-markdown-viewer | nixpkgs-home | onig_sys | `features/docs.nix` |
| russ | nixpkgs-home | libsqlite3-sys | `features/comms.nix` |
| rustdesk-flutter 1.5.0 | nixpkgs | libsodium-sys | `modules/nixos/rustdesk.nix` |

Each has its own probe in `workarounds/default.nix`. Done when every probe is
a removal candidate and every site is reverted.
