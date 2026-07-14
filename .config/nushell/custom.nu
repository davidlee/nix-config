use std/dirs
use std/util "path add"

source ~/.config/nushell/fzf.nu

export alias s = z
export alias si = zi

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

## satan motd
if ("~/notes/satan/motd.txt" | path exists) {
  print $"\e[31m(cat ~/notes/satan/motd.txt)\e[0m\n"
}
