
#!/usr/bin/env nu
use std/dirs
use mod/pi-dev *

use std/util "path add"

path add "~/nushell"
source ./util/keys.nu
use ./aliases.nu *

source ./env.nu
source ./private.local.nu
source ./completion/init.nu
source ./util/nav.nu
source ./util/keys.nu

# after completion.nu: fzf wraps whichever external completer is already registered
source ./fzf.nu
source ./ghostel.nu

# the rest of these live in flakes/modules/nixos/env.nix, so pam_env puts them
# on PATH for GUI apps and systemd --user units too, not just shells.
path add "~/nushell"

$env.config.buffer_editor = ["emacsclient", "-t"]

#
# Functions
#

# attach to a zmx session, creating it in its own systemd scope if new
def za [name: string@"nu-complete zmx sessions", ...cmd] {
  systemd-run --user --scope --collect --quiet zmx attach $name ...$cmd
}

def gcal () {
  gcalcli agenda --calendar $env.WORK_EMAIL
}

def prv [...args: string] {
  git --work-tree=($env.HOME) --git-dir=($env.PRIVATE_GIT_DIR) ...$args
}

def clock [] {
  clock-rs -Bbt --fmt '%d %b' -c blue
}

def nonag [] {
  systemctl --user stop snooze-nag.timer
  systemctl --user stop snooze-nag

}

def nag [] {
  systemctl --user start snooze-nag
  systemctl --user start snooze-nag.timer
}

#
# Init
#

def motd [] {
  # satan motd
  if ("~/satan/motd.txt" | path exists) {
    print $"\e[31m(cat ~/satan/motd.txt)\e[0m\n"
  }
  # sleipnir-doctor, once per login session: the stamp lives in the runtime
  # dir, which logout clears. Problems only; `j doctor` shows everything.
  let stamp = ($env.XDG_RUNTIME_DIR? | default "" | path join "sleipnir-doctor.motd")
  if ($env.XDG_RUNTIME_DIR? != null) and (which sleipnir-doctor | is-not-empty) and not ($stamp | path exists) {
    touch $stamp
    sleipnir-doctor --problems
  }
}

