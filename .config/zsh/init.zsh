autoload zmv

path+=~/.local/bin
path+=~/.cargo/bin
path+=$PWD/bin

typeset -U path

# Fix Alt-BSPC & word navigation:

WORDCHARS='*?_-.[]~=&;!#$%^(){}<>/ '$'\n'
autoload -Uz select-word-style
select-word-style normal
zstyle ':zle:*' word-style unspecified

setopt extended_glob
setopt glob_dots
setopt no_complete_aliases
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushdminus
setopt HIST_REDUCE_BLANKS 
setopt HIST_VERIFY        

source .config/zsh/completions.zsh
source .config/zsh/functions.zsh
source .config/zsh/zstyle.zsh
source .config/zsh/aliases.zsh
