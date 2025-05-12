#
# ENV 
#

# don't load system-wide nixos defaults for ZSH from /etc/zprofile and /etc/zshrc:
setopt no_global_rcs 

export EDITOR=hx
export VISUAL=hx
export PAGER=ov
export MANPAGER='nvim +Man!'

export OBS_DIR=~/workbench

export MCFLY_KEY_SCHEME=vim
export MCFLY_FUZZY=2
export MCFLY_RESULTS=50
export MCFLY_RESULTS_SORT=LAST_RUN
export MCFLY_INTERFACE_VIEW=BOTTOM
