#
# ENV
#
[[ -f $HOME/.config/zsh/work.identity.zsh ]] && source $HOME/.config/zsh/work.identity.zsh

# don't load system-wide nixos defaults for ZSH from /etc/zprofile and /etc/zshrc:
setopt no_global_rcs

export EDITOR="emacsclient"
export VISUAL="emacsclient"
export ALTERNATE_EDITOR=nvim
export PAGER=ov
export GOHOME="~/go"
# export MANPAGER='nvim +Man!'
export MANPAGER='most'

if [[ "Darwin" != "$(uname -o)" ]]; then
  if [[ ! -z "${XDG_RUNTIME_DIR}" ]]; then
    export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/gcr/ssh
  else
    echo "$XDG_RUNTIME_DIR not set, can't set SSH_AUTH_SOCK"
  fi
fi

#
# mcfly
#

export MCFLY_KEY_SCHEME=vim
export MCFLY_FUZZY=2
export MCFLY_RESULTS=50
export MCFLY_RESULTS_SORT=LAST_RUN
export MCFLY_INTERFACE_VIEW=BOTTOM

#
# Secrets
#

export DEEPSEEK_API_KEY="op://API_KEYS/DEEPSEEK_API_KEY/credential"
export OPENROUTER_API_KEY="op://API_KEYS/OPENROUTER_API_KEY/credential"
export MISTRAL_API_KEY="op://API_KEYS/MISTRAL_API_KEY/credential"
export VOYAGE_API_KEY="op://API_KEYS/VOYAGE_API_KEY/credential"
export OPENAI_API_KEY="op://API_KEYS/OPENAI_API_KEY/credential"
export GEMINI_API_KEY="op://API_KEYS/GEMINI_API_KEY/credential"
export ANTHROPIC_API_KEY="op://API_KEYS/ANTHROPIC_API_KEY/credential"

export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
