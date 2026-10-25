export PNPM_HOME="$HOME/.pnpm-global/bin"

autoload zmv

typeset -U PATH path
typeset -U fpath

path=(~/bin
      ~/.local/bin
      ~/.local/bin/scripts
      ~/.cargo/bin $path)

path+=$HOME/.npm-global/bin
path+=$PNPM_HOME
path+=$HOME/go/bin

fpath+=$HOME/.config/zsh/completions

setopt extended_glob
setopt glob_dots
setopt HIST_REDUCE_BLANKS
setopt BEEP

unsetopt FLOW_CONTROL

# Integrations (atuin, carapace, direnv, eza, fzf, oh-my-posh, television,
# yazi, lazygit) are set up by home-manager in .zshrc, after this file.

## Antidote
zstyle ':antidote:bundle' use-friendly-names 'yes'
antidote load ${ZDOTDIR}/.zsh_plugins.txt

source $HOME/.config/zsh/functions.zsh
source $HOME/.config/zsh/functions/fzf.zsh
source $HOME/.config/zsh/aliases.zsh

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
# carapace - https://carapace-sh.github.io/carapace-bin/setup.html
#
export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense' # optional
zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'

#
# zoxide: cd is zoxide. Overrides home-manager's plain init (z, zi stay).
#
eval "$(zoxide init zsh --cmd cd --hook prompt)"

#
# ghostel (emacs terminal) shell integration
#
if [[ "${${INSIDE_EMACS-}%%,*}" = 'ghostel' ]]; then
  source ~/.config/emacs/elpa/ghostel/etc/shell/ghostel.zsh
fi
