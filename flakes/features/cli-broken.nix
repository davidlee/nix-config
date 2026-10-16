# Packages the cli features skip on a platform although their metadata says
# they are available there (DEC-036). Keyed by system; entries are package
# names, compared with lib.getName, so this file stays plain data. Applied by
# ./available.nix.
#
# aarch64-darwin:
# - watchman pulls the folly/fbthrift C++ tower, which fails to build.
# - atuin is not cached for aarch64-darwin (ISS-007). The base
#   modules/home/cli.nix guard stays; no feature lists it today.
# - gtt: depends on alsa-lib, not available on darwin.
# - udiskie: depends on libappindicator-gtk3, not available on darwin.
# - micro (listed as micro-with-wl-clipboard; getName gives pname): depends on wayland, not available on darwin.
# - fsearch: meta.broken, which availableOn ignores.
# - shell_cmds (killall) and yEd: not in cache.nixos.org; the user chose to
#   skip them rather than build locally (SL-008 PHASE-07 VH-1).
# gtt, udiskie, micro and fsearch fail to evaluate; availableOn sees only a package's own
# meta.platforms, not its dependencies (SL-008 PHASE-07, EX-1 extension).
{
  aarch64-darwin = ["watchman" "atuin" "gtt" "udiskie" "micro" "fsearch" "shell_cmds" "yEd"];
}
