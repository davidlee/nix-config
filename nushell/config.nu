#!/usr/bin/env nu

# --------------------------------------------------------------------------------
# Includes
# --------------------------------------------------------------------------------

use std/dirs
use mod/pi-dev *
use std/util "path add"

# WARNING: by decree, do not prepend paths
# to system here, only append - doctrine, npm, cargo, etc
# are set up in env.nix (pam) via flakes, so that they reach
# graphical sessions and we don't all go insane drowning in
# our own piss.
#
# path entries MUST append

path add "~/nushell" --append

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

# --------------------------------------------------------------------------------
# Functions
# --------------------------------------------------------------------------------

$env.config.buffer_editor = ["emacsclient", "-t"]


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
  # sleipnir-doctor problems, once a day (the doctor keeps the stamp).
  # `j doctor` shows everything.
  if (which sleipnir-doctor | is-not-empty) {
    sleipnir-doctor warn --daily
  }
}

