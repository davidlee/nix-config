autoload zmv

path+=~/.local/bin/scripts
path+=~/.local/bin
path+=~/.cargo/bin
path+=~/.npm-global/bin
path+=~/go/bin
path+=$PWD/bin

typeset -U path
typeset -U fpath

fpath+=~/.config/zsh/completions

setopt extended_glob
setopt glob_dots
setopt HIST_REDUCE_BLANKS
setopt BEEP

unsetopt FLOW_CONTROL

# OMZ plugins
# plugins=(colored-man-pages extract 1password copypath copybuffer copyfile colorize eza fancy-ctrl-z kitty rust systemd globalias podman zsh-syntax-highlighting zsh-autosuggestions)
# plugins=(colored-man-pages extract 1password copypath copybuffer copyfile colorize eza fancy-ctrl-z kitty rust systemd globalias podman zsh-syntax-highlighting zsh-autosuggestions)

# zle -N menu-search
# zle -N recent-paths

#
# powerlevel10K
#
[[ ! -f ~/.config/zsh/_p10k.zsh ]] || source ~/.config/zsh/_p10k.zsh
export POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true


## Antidote
zstyle ':antidote:bundle' use-friendly-names 'yes'
antidote load ${ZDOTDIR}/.zsh_plugins.txt
# source ${ZDOTDIR}/.zsh_plugins.zsh

if [[ $OSTYPE = 'linux-gnu' ]]; then
  alias open=xdg-open
fi

source $HOME/.config/zsh/functions.zsh
source $HOME/.config/zsh/functions/fzf.zsh
source $HOME/.config/zsh/zstyle.zsh
source $HOME/.config/zsh/aliases.zsh

#
# override marlonrichert/zsh-autocomplete keybindings:
#

# tab & shift-tab
#bindkey              '^I' menu-select
#bindkey "$terminfo[kcbt]" menu-select
#
## tab + shift-tab cycle listed completions
#bindkey -M menuselect              '^I'         menu-complete
#bindkey -M menuselect "$terminfo[kcbt]" reverse-menu-complete

#
# fix word-style
#
WORDCHARS='*?_.[]~&;!#$%^(){}<>'
autoload -Uz select-word-style
select-word-style normal

#
# autosuggest config
#
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

#
# brew
#
if [ -f /opt/homebrew/bin/brew ]; then
  eval $(/opt/homebrew/bin/brew shellenv);
fi


#
# tmux
#
if [[ -z $TMUX ]]; then
  # (tmux list-sessions && sesh-sessions) || echo "No tmux session found."
  (tmux list-sessions 2>/dev/null | grep -v -E '^_') || echo "No tmux sessions."
fi

#
# carapace - https://carapace-sh.github.io/carapace-bin/setup.html
#
export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense' # optional
zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
source <(carapace _carapace)

#
# skim - https://github.com/skim-rs/skim?tab=readme-ov-file#manually
#
source <(sk --shell zsh)

#
# fzf
#
source <(fzf --zsh)
export FZF_CTRL_T_COMMAND='bfs -type f'
export FZF_CTRL_C_COMMAND='bfs -type d'
export FZF_CTRL_T_OPTS="--bind 'f1:execute(less -f {}),ctrl-y:execute-silent(echo {} | wl-copy),ctrl-o:execute(nvim {})+abort'"

#
# mcfly
#
eval "$(mcfly init zsh)"

#
# zoxide - must be AFTER compinit
#
eval "$(zoxide init zsh --cmd cd --hook prompt)"


#
# silence, nix-direnv
#
export DIRENV_LOG_FORMAT="$(printf "\033[2mdirenv: %%s\033[0m")"
eval "$(direnv hook zsh)"
_direnv_hook() {
  eval "$(direnv export zsh 2> >(egrep -v -e '^....direnv: export' >&2))"
};
