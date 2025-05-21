# manage dotfiles with bare repo:
# 
gc() { git --work-tree=$HOME --git-dir=$HOME/.cfg $* }

# and non-public files, using the same approach w. a private repo
# 
prv() { git --work-tree=$HOME --git-dir=$HOME/.private $* }

# not quite trash, but not treasure either
# 
compost() {
  mv -i $* ~/.compost/
}

#
# watch files matching a pattern, run X on change
# 
watching() {
  watchman-make -p $1 -r $2
}

#
# periodic files
# 

_week() {
  date +"$OBS_DIR/%Y/wk/%Ywk%U.md"
}

_day() {
  date +"$OBS_DIR/%Y/dd/%F.md"
}

_month() {
  date +"$OBS_DIR/%Y/mo/%m.md"
}

_year() {
  date +"$OBS_DIR/%Y/mo/%m.md"
} 

_hxo() {
 hx $($*) -w $OBS_DIR
}

# today's note
day() {
  p=$(_day)
  echo "Daily Note: $p";
  if [ ! -f $p ]; then
    touch $p
    date +"# %F" > $p
    echo "creating $p ..."
    sleep 1
  fi
  hx $p -w $OBS_DIR
}

# this week's note
week() {
  _hxo _week
}

# this month's note
month() {
  _hxo _month
}

#
# FZF
# 
# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" --exclude "result" --exclude ".obsidian" . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" --exclude "result" --exclude ".obsidian" . "$1"
}
