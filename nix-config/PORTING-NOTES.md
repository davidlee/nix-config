# Flake to Non-Flake Port - Sleipnir Configuration

## Overview
Successfully ported the NixOS configuration for Sleipnir from flake-based to npins-based (non-flake) setup.

## What Was Done

### 1. Dependency Management (npins)
All flake inputs have been converted to npins sources:

- `nixpkgs` (nixos-unstable)
- `nix-stable` (nixos-24.11)
- `helix` (master branch)
- `home-manager` (master branch)
- `lix` (tarball)
- `nix-search-tv` (GitRelease)
- `rust-overlay` (master branch)
- `neovim-nightly-overlay` (master branch)
- `zig-overlay` (main branch)
- `zls` (master branch)
- `ucodenix` (GitRelease)

Update dependencies: `npins update`

### 2. Directory Structure
```
nix-config/
├── npins/                  # Pin management
│   ├── default.nix
│   └── sources.json
├── hosts/
│   └── Sleipnir/
│       ├── configuration.nix          # Main system config
│       └── hardware-configuration.nix # Symlink to flakes version
├── home/
│   └── user.nix           # Home-manager config
├── modules/               # Symlink to flakes/modules
├── nixos/                 # Symlink to flakes/nixos
├── home/                  # Symlink to flakes/home
├── default.nix            # Entry point (simple import)
├── nix-factory.sh         # Build script
└── pinning.nix            # Registry/NIX_PATH setup (optional)
```

### 3. Key Differences from Flakes

#### Input Management
- **Flakes**: `flake.lock` with auto-following inputs
- **npins**: `npins/sources.json` with explicit pins, no automatic input following

#### Building
- **Flakes**: `nixos-rebuild switch --flake .#Sleipnir`
- **npins**: `./nix-factory.sh [command]` (sets NIX_PATH appropriately)

#### Overlays
- **Flakes**: Overlays typically exposed via flake outputs
- **npins**: Overlays need to be manually applied in configuration.nix or via nixpkgs.overlays

### 4. What Wasn't Ported (Yet)

- Darwin (macOS) configuration - kept in flakes repo
- Unused modules from flakes repo
- Some overlay configurations may need adjustment

### 5. Build Commands

```bash
# Dry build (test configuration)
./nix-factory.sh dry-build

# Build without switching
./nix-factory.sh build

# Build and switch
./nix-factory.sh switch

# Test configuration (temporary)
./nix-factory.sh test
```

The default command (no args) is `dry-build` for safety during testing.

### 6. Outstanding Items

1. Verify all overlays are properly applied
2. Test actual system switch (not just dry-build)
3. Ensure home-manager integration works correctly
4. Check that `stable` packages are accessible where needed
5. Verify lix/lixPackageSets works in non-flake context

## Notes

- The configuration still uses symlinks to shared modules in ../flakes for now
- This allows easy comparison and gradual migration
- npins doesn't automatically follow inputs like flakes do - each dependency must be explicitly pinned
- Updates are manual: `npins update` or `npins update <name>`
