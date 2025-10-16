#!/usr/bin/env bash

cd $(dirname $0)

# assume that if there are no args, you want to switch to the configuration
cmd=${1:-switch} # change default to switch when we feel comfy
shift

nixpkgs_pin=$(nix eval --raw -f npins/default.nix nixpkgs)
nix_path="nixpkgs=${nixpkgs_pin}:nixos-config=${PWD}/default.nix"

if [[ $cmd == "env" ]]; then
    echo "$nix_path"
    exit 0
fi

# without --fast, nixos-rebuild will compile nix and use the compiled nix to
# evaluate the config, wasting several seconds
echo "Switching with configuration: ${PWD}/default.nix"
sudo env \
    NIX_PATH="${nix_path}" \
    NIXOS_CONFIG="${PWD}/default.nix" \
    nixos-rebuild "$cmd" --no-reexec "$@"
