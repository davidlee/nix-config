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

# disable omz_termsupport_precmd - allow setting ghostty persistent footer with OSC
export DISABLE_AUTO_TITLE=true


# gcr's agent (socket-activated on NixOS). Elsewhere, e.g. Guix's Shepherd
# ssh-agent, keep the agent the session already set.
if [[ "Darwin" != "$(uname -o)" ]]; then
  if [[ -z "${XDG_RUNTIME_DIR}" ]]; then
    echo "XDG_RUNTIME_DIR not set, can't set SSH_AUTH_SOCK"
  elif [[ -S $XDG_RUNTIME_DIR/gcr/ssh ]]; then
    export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/gcr/ssh
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

