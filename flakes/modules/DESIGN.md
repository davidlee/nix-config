# Module Design Principles

## Where does it live?

### NixOS (`modules/nixos/`)
- System services, daemons, kernel, boot, hardware, networking
- Packages that root or system users need (e.g. core CLI tools)
- Anything requiring root permissions or system-level integration
- Stable, slow-moving infrastructure

### Home-manager (`modules/home/`)
- Userland packages and config for david's interactive use
- Must work on both darwin and NixOS (shared across hosts)
- TUI and GUI apps — these break more often and benefit from
  the faster `just home-switch` cycle (no sudo, separate nixpkgs)
- Linux-only home modules go in `modules/home/nixos/` (sway, wayland, etc.)

### Decision checklist
1. Does it need root or serve system users? **nixos**
2. Is it linux-only GUI/desktop? **home/nixos/**
3. Is it a userland tool that works cross-platform? **home**
4. When in doubt: would you expect to find it under system or user config?
   It should be obvious without grepping.

## Configuration style
- Prefer traditional dotfiles over `programs.*` nix wrappers
- When nix config is unavoidable, keep it slim — use `programs.*.enable`
  and point to static config files from the bare repo (see nvim.nix)
- Nix is the package manager, not the configuration language

## Update semantics
- `nixpkgs` — NixOS system, conservative update cycle
- `nixpkgs-home` — home-manager, updated independently and more aggressively
- `stable` (nixos-24.11) — escape hatch for packages broken on unstable

## Overlap
- Each package or config file belongs in exactly one place
- No collisions between NixOS and home-manager providing the same thing
