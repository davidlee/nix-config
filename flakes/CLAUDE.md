# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a NixOS, nix-darwin, and home-manager system configuration repository using Nix Flakes. It manages dotfiles and system configurations for both NixOS (Linux) and macOS systems.

## Key Commands

### System Management
- `nix flake update` - Update all flake inputs
- `sudo nixos-rebuild switch --flake '.#Sleipnir'` - Apply NixOS configuration for host "Sleipnir"
- `just darwin-switch` - Apply macOS configuration for host "fusillade" (uses justfile)
- `nix flake check` - Validate flake configuration
- `nix-collect-garbage -d` - Clean up old generations

### Development
- `nix develop` - Enter development shell (defined in shell.nix)
- `nix run` - Run applications defined in flake outputs
- `nix build` - Build derivations

## Architecture

### Host Configuration Structure
- **NixOS Host**: `hosts/Sleipnir/` - Contains `config.nix` (system config) and `home.nix` (user config)
- **macOS Host**: `darwin/` - Contains Darwin-specific configuration modules

### Module Organization
- `nixos/` - NixOS-specific modules (desktop environments, services, packages)
- `darwin/` - macOS-specific modules (system settings, brew packages)
- `home/` - Home-manager modules (user applications, dotfiles)
- `modules/` - Shared modules across platforms (development tools, shared packages)

### Key Configuration Files
- `flake.nix` - Main flake definition with inputs and outputs
- `nixos/options.nix` - Custom NixOS options (currently for host "Sleipnir")
- `justfile` - Just task runner commands (currently only darwin-switch)

### Specialized Modules
- `nixos/dev.nix` - Development environment setup
- `nixos/wayland.nix` - Wayland compositor configuration
- `nixos/hyprland.nix`, `nixos/gnome.nix`, `nixos/kde.nix`, `nixos/sway.nix` - Desktop environment configs
- `modules/zig.nix` - Zig development environment
- `nixos/rust.nix` - Rust development setup

### File Structure Pattern
The repository follows a modular approach where:
- Host-specific configs import relevant modules from nixos/, darwin/, and modules/
- Home-manager is integrated into both NixOS and Darwin configurations
- Shared development tools are defined in modules/ for cross-platform use

### Important Notes
- The system uses unstable nixpkgs channel with some stable packages from nixos-24.11
- Custom options are defined in nixos/options.nix but not yet fully implemented
- Both systems use Lix (Nix fork) via lix-module input
- The flake includes overlays for Rust, Zig, and other development tools