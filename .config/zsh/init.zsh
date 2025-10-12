autoload zmv

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
plugins=(colored-man-pages extract 1password copypath copybuffer copyfile colorize eza fancy-ctrl-z kitty rust systemd globalias podman zsh-syntax-highlighting zsh-autosuggestions)

zle -N menu-search
zle -N recent-paths

antidote load ${ZDOTDIR}/.zsh_plugins.txt
source ${ZDOTDIR}/.zsh_plugins.zsh

if [[ $OSTYPE = 'linux-gnu' ]]; then
  alias open=xdg-open
fi

source $HOME/.config/zsh/functions.zsh
source $HOME/.config/zsh/zstyle.zsh
source $HOME/.config/zsh/aliases.zsh

# override marlonrichert/zsh-autocomplete keybindings:
bindkey              '^I' menu-select
bindkey "$terminfo[kcbt]" menu-select

bindkey -M menuselect              '^I'         menu-complete
bindkey -M menuselect "$terminfo[kcbt]" reverse-menu-complete


WORDCHARS='*?_.[]~&;!#$%^(){}<>'
autoload -Uz select-word-style
select-word-style normal

# ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_STRATEGY=()

if [ -f /opt/homebrew/bin/brew ]; then
  eval $(/opt/homebrew/bin/brew shellenv);
fi


if [[ -z $TMUX ]]; then
  # (tmux list-sessions && sesh-sessions) || echo "No tmux session found."
  (tmux list-sessions 2>/dev/null | grep -v -E '^_') || echo "No tmux sessions."
fi

# silence, nix-direnv

export DIRENV_LOG_FORMAT="$(printf "\033[2mdirenv: %%s\033[0m")"
eval "$(direnv hook zsh)"
_direnv_hook() {
  eval "$(direnv export zsh 2> >(egrep -v -e '^....direnv: export' >&2))"
};
