# IMP-009: mkNixos sets nixpkgs.hostPlatform from meta.system

MULTIHOST follow-up, by S8. `nixpkgs.hostPlatform` (from hardware config, `mkDefault`) and `meta.system` can disagree. mkNixos should set it at plain priority.
