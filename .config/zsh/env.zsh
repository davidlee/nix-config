#
# ENV
#
[[ -f $HOME/.config/zsh/work.identity.zsh ]] && source $HOME/.config/zsh/work.identity.zsh

# don't load system-wide nixos defaults for ZSH from /etc/zprofile and /etc/zshrc:
setopt no_global_rcs

export EDITOR="emacsclient -t"
export VISUAL="emacsclient"
export ALTERNATE_EDITOR=nvim
export PAGER=ov
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
# Secrets
#

# 1password uris
for provider in DEEPSEEK OPENROUTER MISTRAL VOYAGE GEMINI; do
  key="${provider}_API_KEY"
  export "$key"="op://API_KEYS/${key}/credential"
done

export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1

