#!/usr/bin/env bash
# SL-005 gate probe (design sec-7.1): the measures `just drvs` cannot show.
#
#   gate-probe.sh <outdir> [<flake attr>]   default: nixosConfigurations.Sleipnir
#
# Writes, one file each, for diffing snapshot against snapshot:
#   packages           unique sorted environment.systemPackages drvPaths
#   groups             effective membership: existing groups listing the user
#                      in members, or named in its extraGroups
#   kernelParams       boot.kernelParams, sorted
#   root-options       fileSystems."/".options, as merged
#   system-path-links  every link in the built config.system.path with its
#                      target: shows who won a path collision (RV-011 F-8)
#
# Evaluates with the justfile's system_override, as `just drvs` does. No agents
# registry pin (justfile nixos_pick): nix.registry reaches none of these.
set -euo pipefail

out=${1:?usage: gate-probe.sh <outdir> [<flake attr>]}
attr=${2:-nixosConfigurations.Sleipnir}
user=david
flake=$(cd "$(dirname "$0")/../../.." && pwd)

read -ra overrides <<<"$(just --justfile "$flake/justfile" --evaluate system_override)"
mkdir -p "$out"

nix eval --json "$flake#$attr" "${overrides[@]}" --no-write-lock-file --apply "c: let
  cfg = c.config;
  inherit (c.pkgs) lib;
  inherit (cfg.users) groups;
  extra = cfg.users.users.$user.extraGroups;
in {
  packages = lib.unique (lib.sort lib.lessThan (map (p: p.drvPath) cfg.environment.systemPackages));
  groups = lib.filter (g: lib.elem \"$user\" groups.\${g}.members || lib.elem g extra) (lib.attrNames groups);
  kernelParams = lib.sort lib.lessThan cfg.boot.kernelParams;
  rootOptions = cfg.fileSystems.\"/\".options;
  systemPath = cfg.system.path.drvPath;
}" >"$out/probe.json"

jq -r '.packages[]' "$out/probe.json" >"$out/packages"
jq -r '.groups[]' "$out/probe.json" >"$out/groups"
jq -r '.kernelParams[]' "$out/probe.json" >"$out/kernelParams"
jq -r '.rootOptions[]' "$out/probe.json" >"$out/root-options"

path=$(nix build --no-link --print-out-paths "$(jq -r .systemPath "$out/probe.json")^out")
find "$path" -type l -printf '%P -> %l\n' | sort >"$out/system-path-links"
rm "$out/probe.json"
