# Dotfiles & NixOS, nix-darwin & home-manager system config

[uses this approach](https://www.atlassian.com/git/tutorials/dotfiles) for some things, nix to draw the rest of the owl.

## gui apps

Nix loves having a pretty lean system and per-project flakes.

but gui apps like to be installed system-wide if we want them to be accessible
via launcher / xdg application shortcuts.

Here's a cool trick: dynamically create application shortcuts using fully
qualified paths, and rebuild them using nix-direnv (in ./gui)

keeps core system lean, decouples gui application rebuild from system rebuild.



