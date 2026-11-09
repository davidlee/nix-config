export PNPM_HOME="$HOME/.pnpm-global/bin"

autoload zmv

typeset -U PATH path
typeset -U fpath

# WARNING: by decree, do not prepend paths
# to system here, only append - doctrine, npm, cargo, etc
# are set up in env.nix (pam) via flakes, so that they reach
# graphical sessions and we don't all go insane drowning in
# our own piss.

fpath+=$HOME/.config/zsh/completions

setopt extended_glob
setopt glob_dots
setopt HIST_REDUCE_BLANKS
setopt BEEP

unsetopt FLOW_CONTROL

# Prompt: powerlevel10k (antidote bundle), not oh-my-posh; the zsh feature
# opts zsh out of oh-my-posh's integration.
[[ ! -f ~/.config/zsh/_p10k.zsh ]] || source ~/.config/zsh/_p10k.zsh
export POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true

# Integrations (atuin, carapace, direnv, eza, fzf, television, yazi, lazygit)
# are set up by home-manager in .zshrc, after this file.

#fpath+=( "$HOME/.cache/antidote/michel-kraemer/zsh-patina" )
#source "$HOME/.cache/antidote/michel-kraemer/zsh-patina/zsh-patina.plugin.zsh"

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
# history-substring-search on up/down (trial; replaces omz's prefix-only
# up-line-or-beginning-search). Atuin keeps ^R and leaves the arrows alone.
#
for key in '^[[A' '^[OA'; do bindkey $key history-substring-search-up; done
for key in '^[[B' '^[OB'; do bindkey $key history-substring-search-down; done
unset key

#
# brew
#
if [ -f /opt/homebrew/bin/brew ]; then
  eval $(/opt/homebrew/bin/brew shellenv);
fi

#
# ghostel (emacs terminal) shell integration
#
if [[ "${${INSIDE_EMACS-}%%,*}" = 'ghostel' ]]; then
  source ~/.config/emacs/elpa/ghostel/etc/shell/ghostel.zsh
fi

#
# carapace - https://carapace-sh.github.io/carapace-bin/setup.html
#
export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense' # optional
zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
zstyle ':completion:*:git:*' group-order 'main commands' 'alias commands' 'external commands'
source <(carapace _carapace)

#
# zoxide: cd is zoxide. Overrides home-manager's plain init (z, zi stay).
#
eval "$(zoxide init zsh --cmd cd --hook prompt)"



# Better completion UX
zstyle ':completion:*' menu select
zstyle ':completion:*' rehash true
zstyle ':completion:*' verbose yes

# Case-insensitive + partial matching
zstyle ':completion:*' matcher-list \
    'm:{a-z}={A-Za-z}' \
    'r:|=*' \
    'l:|=* r:|=*'

# Group matches
zstyle ':completion:*' group-name ''

# Group descriptions
zstyle ':completion:*:descriptions' format '%F{yellow}%d%f'

# Colored completion menus
zstyle ':completion:*' list-colors ''

# Better process completion
zstyle ':completion:*:*:*:*:processes' command \
    'ps -u $USER -o pid,user,comm -w -w'

# unseen satan motd; daily doctor problems
motd
