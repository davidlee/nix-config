autoload zmv

path+=~/.local/bin
path+=~/.cargo/bin
path+=$PWD/bin

typeset -U path

setopt extended_glob
setopt glob_dots
setopt HIST_REDUCE_BLANKS
setopt BEEP

unsetopt FLOW_CONTROL

# OMZ plugins
plugins=(colored-man-pages extract taskwarrior 1password copypath copybuffer copyfile colorize eza fancy-ctrl-z kitty rust systemd globalias podman zsh-syntax-highlighting zsh-autosuggestions)

zle -N menu-search
zle -N recent-paths

antidote load ${ZDOTDIR}/.zsh_plugins.txt
source ${ZDOTDIR}/.zsh_plugins.zsh

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

if [ -z "$TMUX" ]; then
  default_session_name='default'
  wanna_mux=`gum choose --header="Psst ... wanna mux?" yeah nah "gimme something special"`

  if [[ $wanna_mux = yeah ]]; then
    if [ -z "$TMUX" ]; then
      ~/.local/bin/tmx $default_session_name
    fi
  else
    if [[ $wanna_mux = "gimme something special" ]]; then
      session_name=`gum input --placeholder='session name'`
      exec ~/.local/bin/tmx $session_name
    else
      echo "have it your way."
    fi
  fi
fi

