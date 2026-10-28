# manage dotfiles with bare repo:
#
# gc() { git --work-tree=$HOME --git-dir=$HOME/.cfg $* }

gcal() {
  gcalcli agenda --calendar $WORK_EMAIL
}
# and non-public files, using the same approach w. a private repo
#
prv() { git --work-tree=$HOME --git-dir=$HOME/.private $* }

#
# file utils
#
mkcd () {
  \mkdir -p "$1"
  cd "$1"
}

tempe () {
  cd "$(mktemp -d)"
  chmod -R 0700 .
  if [[ $# -eq 1 ]]; then
    \mkdir -p "$1"
    cd "$1"
    chmod -R 0700 .
  fi
}

#################
# compost:
#
# not quite trash, but not treasure either
#
compost() {
  mv -i $* ~/.compost/
}

######################
# watch files matching a pattern, run X on change
#
wm() {
  watchman-make -p $1 -r $2
}

#
# motd [-v]: the satan motd if unseen, then sleipnir-doctor problems once a
# day (the doctor keeps that stamp). -v: both, regardless. `j doctor` shows
# everything.
#
motd() {
  local msg=~/satan/motd.txt seen=${XDG_STATE_HOME:-$HOME/.local/state}/motd/seen
  local all=0
  [[ $1 == -v ]] && all=1
  # $seen carries the mtime of the last message shown
  if [[ -f $msg ]] && { (( all )) || [[ ! -e $seen || $msg -nt $seen ]] }; then
    print -r -- $'\e[31m'"$(<$msg)"$'\e[0m\n'
    mkdir -p ${seen:h} && touch -r $msg $seen
  fi
  if (( $+commands[sleipnir-doctor] )); then
    if (( all )); then sleipnir-doctor warn; else sleipnir-doctor warn --daily; fi
  fi
}

#
# navigation
#

git-root() { git rev-parse --show-toplevel }
gr() { cd "$(git-root)" }

# print an fzf-picked path under $1, relative to it; $2 pre-fills fzf, which
# takes a sole match itself; further args go to fd
fd-pick() {
  fd . "${@:3}" --base-directory "$1" --strip-cwd-prefix=always |
    fzf --query="$2" --select-1 --exit-0
}

# cd to an fzf-picked subdir of $1; further args go to fd
cd-pick() { local sub; sub=$(fd-pick "$1" "" -t d "${@:2}") && cd "$1/$sub" }

# zoxide's match for $1, or the git root
cz-base() { if (( $# )); then zoxide query "$1"; else git-root; fi }

# cz [query]: pick a subdir of the git root, or of a zoxide dir; czh: incl. hidden
cz() { local base; base=$(cz-base "$@") && cd-pick "$base" }
czh() { local base; base=$(cz-base "$@") && cd-pick "$base" --hidden }

# pick from favourite dirs
ch() {
  local dir
  dir=$(gum choose ~/dev/doctrine ~/.config/emacs ~/dev/notes ~/flakes ~/nushell \
    ~/Downloads ~/.local/src ~/.local/bin) && cd "$dir"
}

#
# zmx: attach to a session, creating it in its own systemd scope if new
#
za() { systemd-run --user --scope --collect --quiet zmx attach "$@" }
_za() { (( CURRENT == 2 )) && compadd -- ${(f)"$(zmx list --short 2>/dev/null)"} }
compdef _za za

#
# snooze-nag
#
nag() { systemctl --user start snooze-nag snooze-nag.timer }
nonag() { systemctl --user stop snooze-nag.timer snooze-nag }

#
# editing
#

# emacsclient; options replace the default mode: reuse the GUI frame without
# waiting (dl-umbriel focuses it), or the tty when there is no display
e() {
  if [[ $1 == -* ]]; then emacsclient "$@"
  elif [[ -n $WAYLAND_DISPLAY ]]; then emacsclient -r -n "$@"
  else emacsclient -t "$@"; fi
}

# e a picked file; -options go to e
# ez [opts] [query]: under the git root, or under zoxide's dir for query
# ne [opts] [query]: a note; query pre-fills fzf
ez() {
  local base sub
  base=$(cz-base ${@:#-*}) && sub=$(fd-pick $base "" -t f) && e ${(M)@:#-*} $base/$sub
}
ne() {
  local sub
  sub=$(fd-pick ~/notes "${(j: :)@:#-*}" -t f -e org -e md) && e ${(M)@:#-*} ~/notes/$sub
}

#
# Color Palette
#
colors () {
  for i in {0..255}
  do
  print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+$'\n'}
  done
}

#
# FZF
#

#
# fzf - use bfs over fd
#
my_bfs_excludes="-exclude -name .git -exclude -name result -exclude -name .obsidian"

FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --ansi"
FZF_ALT_C_COMMAND="bfs -color -mindepth 1 $my_bfs_excludes -type d -printf '%P\n' 2>/dev/null"

_fzf_compgen_path() {
    bfs -H "$1" -color $my_bfs_excludes 2>/dev/null
}

_fzf_compgen_dir() {
    bfs -H "$1" -color $my_bfs_excludes -type d 2>/dev/null
}
