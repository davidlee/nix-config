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

fzd() { 
  base=$(zoxide query $1);
  dir="$base/$(fd . -t d --base-directory $base --strip-cwd-prefix=always | fzf)"; 
  chdir $dir 
}

#
# find & edit a file in a zoxide dir
#
fze() { 
  base=$(zoxide query $1);
  dir="$base/$(fd . -t f --base-directory $base --strip-cwd-prefix=always | fzf)"; 
  chdir $base 
  $VISUAL $dir 
}

#################################################################################
# periodic files
#################################################################################

export OBS_DIR=~/workbench
export DAY_NOTE_FORMAT="$OBS_DIR/%Y/dd/%F.md"
export WEEK_NOTE_FORMAT="$OBS_DIR/%Y/wk/%Ywk%U.md"
export MONTH_NOTE_FORMAT="$OBS_DIR/%Y/mo/%m.md"
export YEAR_NOTE_FORMAT="$OBS_DIR/%Y.md"

_day_note_path() { date +$DAY_NOTE_FORMAT }
_week_note_path() { date +$WEEK_NOTE_FORMAT }
_month_note_path() { date +$MONTH_NOTE_FORMAT }
_year_note_path() { date +$YEAR_NOTE_FORMAT }

_ensure_periodic_note_exists() {
  if [ ! -f $1 ]; then
    echo "# ${2}\n" >> $1
    echo "creating $1 ..."
    sleep 1
  fi
}

_edit_periodic_note() {
  _ensure_periodic_note_exists $1 $2; # path, heading
  hx $1 -w $OBS_DIR
}

day() { _edit_periodic_note $(_day_note_path) `date +"%F"` }
week() { _edit_periodic_note $(_week_note_path) `date +"%Ywk%U"` }
month() { _edit_periodic_note $(_month_note_path) `date +"%m"` }
year() { _edit_periodic_note $(_year_note_path) `date +"%Y"` }

_interstitial_status() {
  filepath="${1:-$(_day_note_path)}";
  # echo $filepath >&2;

  if [ ! -f $filepath ]; then
    echo "-1 missing" >&2;
    return 1;
  fi

  find $filepath -mmin +15;
  if [ ! $? -eq 0 ]; then
    echo "-1 old" >&2;
    return 2;
  fi

  echo "ok" >&2;
  return 0;
}

#
# Color Pallette
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

