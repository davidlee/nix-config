# CHR-003: One importPkgs helper and one commonArgs builder

MULTIHOST follow-ups (S9). `import <src> { system; allowUnfree; overlays }` appears four times and `agentsOverlay` is bound twice (flake.nix, hosts.nix); specialArgs differ per kind (darwin: no `stable`, has `pkgs`). One `importPkgs` helper and one `commonArgs` builder in hosts.nix; move legacyPackages/packages beside it so flake.nix is inputs + templates.
