# GUI Apps

This is a sneaky (you might even say elegant) hack.

We use nix-direnv to install a local "dev environment" with GUI apps, in order
to keep them independently installable from the base NixoOS + Home Manager
configuration.

There's a post-activation hook that syncs application shortcuts in
`.local/share/applications/gui` using fully qualified paths, so they're indexed
and runnable from application launchers.

use `nix flake update` and enter the directory to update.


