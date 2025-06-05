#
# ENV
#

# don't load system-wide nixos defaults for ZSH from /etc/zprofile and /etc/zshrc:
setopt no_global_rcs

export EDITOR=nvim
export VISUAL=nvim
export PAGER=ov
# export MANPAGER='nvim +Man!'
export MANPAGER='most'

#
# mcfly
#

export MCFLY_KEY_SCHEME=vim
export MCFLY_FUZZY=2
export MCFLY_RESULTS=50
export MCFLY_RESULTS_SORT=LAST_RUN
export MCFLY_INTERFACE_VIEW=BOTTOM

#################################################################################
# periodic files
#################################################################################

export OBS_DIR=~/workbench

export OBS_DAY_NOTE_FORMAT="%Y/dd/%F.md"
export OBS_WEEK_NOTE_FORMAT="%Y/wk/%Ywk%U.md"
export OBS_MONTH_NOTE_FORMAT="%Y/mo/%m.md"
export OBS_YEAR_NOTE_FORMAT="%Y.md"

export DAY_NOTE_FORMAT="$OBS_DIR/$OBS_DAY_NOTE_FORMAT"
export WEEK_NOTE_FORMAT="$OBS_DIR/$OBS_WEEK_NOTE_FORMAT"
export MONTH_NOTE_FORMAT="$OBS_DIR/$OBS_MONTH_NOTE_FORMAT"
export YEAR_NOTE_FORMAT="$OBS_DIR/$OBS_YEAR_NOTE_FORMAT"

if [[ $(uname -s) = 'Darwin' ]]; then
  TASKWARRIOR_PRIMARY_HOST=0
else
  TASKWARRIOR_PRIMARY_HOST=1
fi

# don't create recurring Taskwarrior tasks on multiple synced devices
export TASKWARRIOR_RECURRENCE=1 # $TASKWARRIOR_PRIMARY_HOST

#
# Secrets - private bare repo (non-critical only; use 1password encryption where we really care)
#

source ~/.config/zsh/secrets.zsh
