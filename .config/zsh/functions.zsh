# manage dotfiles with bare repo:
# 
gc() { git --work-tree=$HOME --git-dir=$HOME/.cfg $* }

# and non-public files, using the same approach w. a private repo
# 
prv() { git --work-tree=$HOME --git-dir=$HOME/.private $* }

# nix formatter convenience
# ex usage: om sudo nixos-rebuild switch
#
om() { $* --log-format internal-json -v |& nom --json }

# not quite trash, but not treasure either
# 
compost() {
  mv -i $* ~/.compost/
}

#
# periodic files
# 

_week_note() {
  date +"$ORG_DIR/%Y/wk/%Ywk%U.md"
}

_day_note() {
  date +"$ORG_DIR/%Y/dd/%F.md"
}

_month_note() {
  date +"$ORG_DIR/%Y/mo/%m.md"
}

_year_note() {
  date +"$ORG_DIR/%Y/mo/%m.md"
}

_edit_note() {
  $VISUAL $($*) -w $ORG_DIR
}

# today's note
day() {
  _edit_note _day_note
}

# this week's note
week() {
  _edit_note _week_note
}

# this month's note
month() {
  _edit_note _month_note
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
