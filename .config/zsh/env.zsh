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

export OBS_DIR=~/workbench

export MCFLY_KEY_SCHEME=vim
export MCFLY_FUZZY=2
export MCFLY_RESULTS=50
export MCFLY_RESULTS_SORT=LAST_RUN
export MCFLY_INTERFACE_VIEW=BOTTOM

#
# Secrets - private bare repo (non-critical only; use 1password encryption where we really care)
#

source ~/.config/zsh/secrets.zsh
