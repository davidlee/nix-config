use std/dirs
use std/util "path add"

source ~/.config/nushell/fzf.nu
source ~/.config/nushell/private.local.nu

export alias c = z
export alias ci = zi

export alias j = just
export alias d = doctrine

export alias em = emacs --tty
export alias emn = emacs --tty --no-wait
export alias emc = emacsclient

export alias dev = cd ~/dev

export alias zed = zeditor
export alias lg = lazygit

# TODO conditional $OS_TYPE == 'linux-gnu'
#if ((^which open err> /dev/null) | path exists) { } else {
#export alias open = xdg-open
#}
export alias st = git status

# misc

# export alias clock = r#'clock-rs --fmt "%d %b"'#
# export alias cl = "clock-rs -Bbt --fmt '%Y-%m-%d'";
# export alias arch = "distrobox enter archlinux";

$env.config.show_banner = false
$env.config.buffer_editor = ["emacs", "--tty"]
$env.CARGO_HOME = "~/.cargo"

path add "~/.local/bin"
path add "~/go/bin"
path add "~/.pnpm-global/bin"
path add "~/.npm-global/bin"
path add "~/.local/bin/scripts"
path add ($env.CARGO_HOME | path join "bin")

$env.EDITOR = "emacs --tty"
$env.VISUAL = "emacs --tty"
$env.ALTERNATE_EDITOR = "nvim"
$env.PAGER = "ov"
$env.MANPAGER = "most"
$env.PRIVATE_GIT_DIR = ($env.HOME | path join ".private")

## satan motd
if ("~/notes/satan/motd.txt" | path exists) {
  print $"\e[31m(cat ~/notes/satan/motd.txt)\e[0m\n"
}

def gcal () {
  gcalcli agenda --calendar $env.WORK_EMAIL
}

def prv [...args: string] {
  git --work-tree=($env.HOME) --git-dir=($env.PRIVATE_GIT_DIR) ...$args
}

def _cz [dir=""] {
  _fd_fzf
}
export alias cz = cd (_cz)

def _czi [dir=""] {
  _fd_fzf '-I'
}
export alias czi = cd (_cz)

## helpers

def _dir_fd_fzf [base: string, ...fd_args: string] {
  echo ($base |
    path join (fd . ...$fd_args -t d --base-directory $base --strip-cwd-prefix=always | fzf)
  )
}

def _fd_fzf [...fd_args: string] {
  let base = (git rev-parse --show-toplevel)
  _dir_fd_fzf $base ...$fd_args
}
