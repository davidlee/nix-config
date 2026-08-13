#!/usr/bin/env bash

cmd=${1:-switch}
shift

nixos-rebuild \
  --log-format internal-json \
  --flake /home/david/flakes/\#Sleipnir \
  -v \
  --show-trace \
  --no-reexec \
  $cmd $@ |& nom --json
