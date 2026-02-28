# Dotfiles & NixOS, nix-darwin & home-manager system config

[uses this approach](https://www.atlassian.com/git/tutorials/dotfiles) for some things, nix to draw the rest of the owl.

## Principles

- keep a fairly lean core system
- separate userspace & system build using home-manager
- prefer dotfiles over nix. Include raw dotfiles (custom config) in generated nix configs.
- share the things worth sharing (especially cli tooling) across Darwin / macOS
- minimal but secure secret management (out of version control)
- use nix-direnv for project-local dev environments.
- use templates to make this easy
- prefer unstable; pin to stable as an escape hatch for broken packages
- use modules for maintainability and easy coarse-grained configuration changes
  see [design doc](./modules/DESIGN.md`)




