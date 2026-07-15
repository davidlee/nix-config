use std/dirs
use modules/nav *

source fzf.nu
source private.local.nu

#
# Environment
#

$env.config.show_banner = false
$env.config.buffer_editor = ["emacs", "--tty"]

$env.EDITOR = "emacs --tty"
$env.VISUAL = "emacs --tty"
$env.ALTERNATE_EDITOR = "nvim"
$env.PAGER = "ov"
$env.MANPAGER = "most"
$env.CARGO_HOME = "~/.cargo"
$env.PRIVATE_GIT_DIR = ($env.HOME | path join ".private")

path add "~/.local/bin"
path add "~/.local/bin/scripts"
path add ($env.CARGO_HOME | path join "bin")
path add "~/go/bin"
path add "~/.pnpm-global/bin"
path add "~/.npm-global/bin"

#
# Aliases
#

export alias c = z
export alias ci = zi

export alias j = just
export alias d = doctrine

export alias g = dirs goto
export alias n = dirs next
export alias p = dirs prev

export alias em = emacs --tty
export alias emn = emacs --tty --no-wait
export alias emc = emacsclient

export alias dev = cd ~/dev

export alias zed = zeditor
export alias lg = lazygit
export alias st = git status

if (uname | get operating-system ) == 'GNU/Linux' {
  export alias open = xdg-open
}

export alias arch = distrobox enter archlinux;

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

def tree [...eza_params: string] {
  eza --tree $...eza_params
}

#
# Init
#

# satan motd
if ("~/notes/satan/motd.txt" | path exists) {
  print $"\e[31m(cat ~/notes/satan/motd.txt)\e[0m\n"
}


