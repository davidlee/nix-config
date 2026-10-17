#!/usr/bin/env bash

# run.sh <cmd> <host> [nixos-rebuild args…]   (host defaults to $(hostname))
set -o pipefail # a failed build must not exit with nom's 0
cmd=${1:-switch}
host=${2:-$(hostname)}
shift $(($# < 2 ? $# : 2))

nixos-rebuild \
  --log-format internal-json \
  --flake "/home/david/flakes#$host" \
  -v \
  --show-trace \
  --no-reexec \
  "$cmd" "$@" |& nom --json
