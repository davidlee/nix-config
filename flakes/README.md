# Dotfiles & NixOS system config

See [this guide](https://www.atlassian.com/git/tutorials/dotfiles) to grok how non-nixed dotfiles are managed.

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

# nixos / darwin config with flakes


todo
- [ ] dyndns + sshd
- [ ] secrets with maybe https://github.com/brizzbuzz/opnix
- [ ] wireguard & shadowsocks
- [ ] home-manager: independent runner
- [ ] darwin actually

issues
- usb hotplug
