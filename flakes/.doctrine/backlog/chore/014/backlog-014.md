# CHR-014: Find out whether hardware.i2c is needed on Sleipnir; drop if not

`hardware.i2c.enable` (from `modules/nixos/util.nix`) has no visible
consumer in the repo or `~/.config` (ddcutil? noctalia brightness?). The user
does not recall why it was added. SL-007 (DEC-028) moves it to Sleipnir's
machine config unchanged; find a consumer or drop it.
