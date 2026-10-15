# IMP-003: Features add their own user groups

`modules/nixos/user.nix` lists docker, libvirtd, caddy, gamemode, jackaudio centrally, whether or not those features are selected. Each feature should append `users.users.<user>.extraGroups` itself (list options merge). Fold into the migration of each owning feature. (MULTIHOST S9.)
