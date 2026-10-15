# IMP-003: Features add their own user groups

`modules/nixos/user.nix` lists docker, libvirtd, caddy, gamemode, jackaudio centrally, whether or not those features are selected. Each feature should append `users.users.<user>.extraGroups` itself (list options merge). Fold into the migration of each owning feature. (MULTIHOST S9.)

SL-005: docker and libvirtd removed from user.nix; `virt.qemu` adds libvirtd, and rootless docker needs no group. `dev`, `caddy` and `jackaudio` also name groups that do not exist on Sleipnir.

SL-006: gamemode (now added by `games.gamescope`) and caddy left `user.nix`.
Remaining: jackaudio.
