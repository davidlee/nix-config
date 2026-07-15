#!/usr/bin/env nu

#
# Functions
#

def _fd_fzf [...fd_args: string] {
  let base = git-root
  _dir_fd_fzf $base ...$fd_args
}

def _dir_fd_fzf [base: string, ...fd_args: string] {
  echo ($base |
    path join (fd . ...$fd_args -t d --base-directory $base --strip-cwd-prefix=always | fzf))
}

export def git-root [] {
  (git rev-parse --show-toplevel)
}

#
# Aliases
#

export alias cz = cd (_fd_fzf)
export alias czh = cd (_fd_fzf '--hidden')
export alias cgr = cd (git-root)

