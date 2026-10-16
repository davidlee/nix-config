nixpkgs enables kernel Rust by default: `rustByDefault` in `pkgs/os-specific/linux/kernel/common-config.nix` (~line 48) is true for kernels >= 6.12 on x86_64, aarch64, loongarch64 (and riscv64 with a non-GNU compiler); `withRust = forceRust || (rustAvailable && rustByDefault)`.

A `boot.kernelPatches = [{ name = "Rust Support"; patch = null; features.rust = true; }]` entry therefore yields a byte-identical `.config` (verified on 7.2.9, sha256 f6053463…, SL-007 PHASE-06). It only changes the intermediate config from `RUST? y` to `RUST y`, which makes the kernel a different derivation that cache.nixos.org does not have — a long local kernel build for nothing.

Drop such a patch. To check first: build `config.boot.kernelPackages.kernel.configfile` and `pkgs.linuxPackages_latest.kernel.configfile` (both substitute) and `cmp` them.
