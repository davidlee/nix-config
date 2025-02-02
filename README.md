# Dotfiles & NixOS system config

see [.cfg/REAME.md] for stuff not nixed (managed using a bare git repo)


Installation:

use zsh.

```
echo ".cfg" >> ~/.gitignore
git clone --bare git@github.com:davidlee/clean-beak.git

gc() { git --work-tree=$HOME --git-dir=$HOME/.cfg $* }

gc checkout
gc config --local status.showUntrackedFiles no
# manage any conflicts

```
then use nixos to draw the rest of the owl.

## todo:
- [ ] zip this together with nix darwin config

