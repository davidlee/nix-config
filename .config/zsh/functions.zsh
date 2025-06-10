############
# git x dotfiles
#

# manage dotfiles with bare repo:
#
gc() { git --work-tree=$HOME --git-dir=$HOME/.cfg $* }

# and non-public files, using the same approach w. a private repo
#
prv() { git --work-tree=$HOME --git-dir=$HOME/.private $* }

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
# find subdir in a zoxide dir
#

cz() {
  base=$(zoxide query $1);
  dir="$base/$(fd . -t d --base-directory $base --strip-cwd-prefix=always | fzf)";
  chdir $dir
}

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
oj() {
  uri="obsidian://new?vault=workbench&file=`date +$OBS_DAY_NOTE_FORMAT`"
  echo "opening $uri"
  open $uri
}

#################################################################################
# periodic files
#################################################################################

_rel_day_note_path() { date +$OBS_DAY_NOTE_FORMAT }
_rel_week_note_path() { date +$OBS_WEEK_NOTE_FORMAT }
_rel_month_note_path() { date +$OBS_MONTH_NOTE_FORMAT }
_rel_year_note_path() { date +$OBS_YEAR_NOTE_FORMAT }

_day_note_path() { date +$DAY_NOTE_FORMAT }
_week_note_path() { date +$WEEK_NOTE_FORMAT }
_month_note_path() { date +$MONTH_NOTE_FORMAT }
_year_note_path() { date +$YEAR_NOTE_FORMAT }

# $1 = vault-relative path
_ensure_periodic_note_exists() {
  abs_path="$OBS_VAULT_PATH/$1"
  if [ ! -f $abs_path ]; then
    echo "creating note with Obsidian: $1" # ensure we apply the template
    uri="obsidian://new?vault=workbench&file=$1"
    open $uri
  fi
}

_obs_uri() {
  uri="obsidian://new?vault=workbench&file=$1"
}

# $1 = vault-relative path, $2 = heading
_edit_periodic_note() {
  _ensure_periodic_note_exists $1 $2;
  sleep 1
  $VISUAL "$OBS_VAULT_PATH/$1"
}

daily() { _edit_periodic_note $(_rel_day_note_path) `date +"%F"` }
weekly() { _edit_periodic_note $(_rel_week_note_path) `date +"%Ywk%U"` }
monthly() { _edit_periodic_note $(_rel_month_note_path) `date +"%m"` }
yearly() { _edit_periodic_note $(_rel_year_note_path) `date +"%Y"` }

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


#
# Sesh https://github.com/joshmedeski/sesh?tab=readme-ov-file
#

function sesh-sessions() {
  {
    exec </dev/tty
    exec <&1
    local session
    session=$(sesh list -t -c | fzf --height 40% --reverse --border-label ' sesh ' --border --prompt '⚡  ')
    zle reset-prompt > /dev/null 2>&1 || true
    [[ -z "$session" ]] && return
    sesh connect $session
  }
}

# hit <Esc>s for a sesh-sessions popup
zle     -N             sesh-sessions
bindkey -M emacs '\es' sesh-sessions
bindkey -M vicmd '\es' sesh-sessions
bindkey -M viins '\es' sesh-sessions

