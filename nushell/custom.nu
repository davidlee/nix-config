use std/dirs
use modules/nav *

source fzf.nu
source private.local.nu

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
$env.CARGO_HOME = "~/.cargo"
$env.PRIVATE_GIT_DIR = ($env.HOME | path join ".private")


$env.DEEPSEEK_API_KEY = "op://API_KEYS/DEEPSEEK_API_KEY/credential"
$env.OPENROUTER_API_KEY = "op://API_KEYS/OPENROUTER_API_KEY/credential"
$env.MISTRAL_API_KEY = "op://API_KEYS/MISTRAL_API_KEY/credential"
$env.VOYAGE_API_KEY = "op://API_KEYS/VOYAGE_API_KEY/credential"
$env.OPENAI_API_KEY = "op://API_KEYS/OPENAI_API_KEY/credential"
$env.GEMINI_API_KEY = "op://API_KEYS/GEMINI_API_KEY/credential"
$env.ANTHROPIC_API_KEY = "op://API_KEYS/ANTHROPIC_API_KEY/credential"

$env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = 1

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

export alias e = emacs -nw
export alias ee = emacsclient -e
export alias em = emacs
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

export alias ch = cd (gum choose ~/dev/doctrine ~/dev/.emacs.d ~/dev/notes ~/flakes ~/Downloads ~/.local/src/ ~/.local/bin)

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


#
# Init
#

# satan motd
if ("~/notes/satan/motd.txt" | path exists) {
  print $"\e[31m(cat ~/notes/satan/motd.txt)\e[0m\n"
}


