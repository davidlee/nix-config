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
# satan motd, then sleipnir-doctor problems once a day (the doctor keeps
# the stamp). `j doctor` shows everything.
#
motd() {
  [[ -f ~/satan/motd.txt ]] && print -r -- $'\e[31m'"$(<~/satan/motd.txt)"$'\e[0m\n'
  (( $+commands[sleipnir-doctor] )) && sleipnir-doctor warn --daily
}

#
# navigation
#

git-root() { git rev-parse --show-toplevel }
gr() { cd "$(git-root)" }

# cd to an fzf-picked subdir of $1; further args go to fd
cd-pick() {
  local base=$1 sub
  sub=$(fd . -t d "${@:2}" --base-directory "$base" --strip-cwd-prefix=always | fzf) &&
    cd "$base/$sub"
}

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
# find & edit a file in a zoxide dir
#
vfe() {
  base=$(zoxide query $1);
  dir="$base/$(fd . -t f --base-directory $base --strip-cwd-prefix=always | fzf)";
  chdir $base
  $VISUAL $dir
}

#
# find & edit a file in the notes dir
#
vn() {
  base=$OBS_VAULT_PATH
  dir="$base/$(fd . -t f --base-directory $base --strip-cwd-prefix=always | fzf)";
  chdir $base
  $VISUAL $dir
}

# like ij (interstitial writing) but open note in obsidian
# oj() {
#   uri="obsidian://new?vault=workbench&file=`date +$OBS_DAY_NOTE_FORMAT`"
#   echo "opening $uri"
#   open $uri
# }

#################################################################################
# periodic files
#################################################################################

# _rel_day_note_path() { date +$OBS_DAY_NOTE_FORMAT }
# _rel_week_note_path() { date +$OBS_WEEK_NOTE_FORMAT }
# _rel_month_note_path() { date +$OBS_MONTH_NOTE_FORMAT }
# _rel_year_note_path() { date +$OBS_YEAR_NOTE_FORMAT }
#
# _day_note_path() { date +$DAY_NOTE_FORMAT }
# _week_note_path() { date +$WEEK_NOTE_FORMAT }
# _month_note_path() { date +$MONTH_NOTE_FORMAT }
# _year_note_path() { date +$YEAR_NOTE_FORMAT }
#
# # $1 = vault-relative path
# _ensure_periodic_note_exists() {
#   abs_path="$OBS_VAULT_PATH/$1"
#   if [ ! -f $abs_path ]; then
#     echo "creating note with Obsidian: $1" # ensure we apply the template
#     uri="obsidian://new?vault=workbench&file=$1"
#     open $uri
#   fi
# }
#
# _obs_uri() {
#   uri="obsidian://new?vault=workbench&file=$1"
# }
#
# # $1 = vault-relative path, $2 = heading
# _edit_periodic_note() {
#   _ensure_periodic_note_exists $1 $2;
#   sleep 1
#   $VISUAL "$OBS_VAULT_PATH/$1"
# }
#
# daily() { _edit_periodic_note $(_rel_day_note_path) `date +"%F"` }
# weekly() { _edit_periodic_note $(_rel_week_note_path) `date +"%Ywk%U"` }
# monthly() { _edit_periodic_note $(_rel_month_note_path) `date +"%m"` }
# yearly() { _edit_periodic_note $(_rel_year_note_path) `date +"%Y"` }
#
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
