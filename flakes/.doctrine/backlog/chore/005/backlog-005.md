# CHR-005: zsh aliases hard-code #Sleipnir

`~/.config/zsh/aliases.zsh` `nrs`/`nrb` hard-code `#Sleipnir`. Outside flakes/; use hostname.

## Resolution (2026-10-15)

`nrs`/`nrb` use `#$HOST` (zsh's hostname parameter, expanded when aliases.zsh is sourced),
matching the justfile's hostname-based host selection.
