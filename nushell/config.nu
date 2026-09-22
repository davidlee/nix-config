
#!/usr/bin/env nu
use std/dirs
use modules/nav *
use modules/niri-wm *

use std/util "path add"

path add "~/nushell"
use ./keys.nu
use ./aliases.nu *

source ./fzf.nu
source ./private.local.nu
source ./just.nu
source ./env.nu
source "~/.emacs.d/elpa/ghostel/etc/shell/ghostel.nu"

# the rest of these live in flakes/modules/nixos/env.nix, so pam_env puts them
# on PATH for GUI apps and systemd --user units too, not just shells.
path add "~/nushell"

#
# Functions
#

def gcal () {
  gcalcli agenda --calendar $env.WORK_EMAIL
}

def prv [...args: string] {
  git --work-tree=($env.HOME) --git-dir=($env.PRIVATE_GIT_DIR) ...$args
}

def clock [] {
  clock-rs -Bbt --fmt '%d %b' -c blue
}

#
# Init
#

def motd [] {
  # satan motd
  if ("~/satan/motd.txt" | path exists) {
    print $"\e[31m(cat ~/satan/motd.txt)\e[0m\n"
  }
}

