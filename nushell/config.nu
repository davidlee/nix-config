
#!/usr/bin/env nu
use std/dirs
use modules/nav *
use modules/niri-wm *

use std/util "path add"

path add "~/nushell"

source fzf.nu
source private.local.nu
source just.nu
use ./keys.nu
source "~/.emacs.d/elpa/ghostel/etc/shell/ghostel.nu"
#
# Environment
#

$env.config.show_banner = false
$env.config.buffer_editor = ["nvim"]

$env.EDITOR = "nvim"
$env.VISUAL = "nvim"
$env.ALTERNATE_EDITOR = "nvim"
$env.PAGER = "ov"
$env.MANPAGER = "nvim +Man!"
$env.CARGO_HOME = $"($env.HOME)/.cargo"
$env.PRIVATE_GIT_DIR = ($env.HOME | path join ".private")

$env.DEEPSEEK_API_KEY = "op://API_KEYS/DEEPSEEK_API_KEY/credential"
# $env.OPENROUTER_API_KEY = "op://API_KEYS/OPENROUTER_API_KEY/credential"
# $env.MISTRAL_API_KEY = "op://API_KEYS/MISTRAL_API_KEY/credential"
# $env.VOYAGE_API_KEY = "op://API_KEYS/VOYAGE_API_KEY/credential"
# $env.OPENAI_API_KEY = "op://API_KEYS/OPENAI_API_KEY/credential"
# $env.OPENAI_ALT_API_KEY = "op://API_KEYS/OPENAI_ALT_API_KEY/credential"
# $env.GEMINI_API_KEY = "op://API_KEYS/GEMINI_API_KEY/credential"
# $env.ANTHROPIC_API_KEY = "op://API_KEYS/ANTHROPIC_API_KEY/credential"

$env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = 1

# the rest of these live in flakes/modules/nixos/env.nix, so pam_env puts them
# on PATH for GUI apps and systemd --user units too, not just shells.
path add "~/nushell"

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

export alias e  = emacsclient -tty
export alias ee = emacsclient -e
export alias en = emacs -nw --no-wait
export alias ec = emacsclient

export alias dev = cd ~/dev
export alias cfg = cd ~/.config
export alias fl = cd ~/flakes
export alias nuc = vi ~/nushell/custom.nu
export alias notes = cd ~/notes

export alias zed = zeditor
export alias lg = lazygit
export alias st = git status

export alias la = eza -a
export alias ll = eza -l
export alias lla = eza -la
export alias lls = ls
export alias lt = eza --tree
export alias tree = eza --tree

export alias ch = cd (gum choose ~/dev/doctrine ~/dev/.emacs.d ~/dev/notes ~/flakes ~/nushell ~/Downloads ~/.local/src/ ~/.local/bin)

export alias arch = distrobox enter archlinux;

export alias fg = job unfreeze

alias o = start

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

