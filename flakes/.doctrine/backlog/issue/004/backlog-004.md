# ISS-004: nixpkgs.overlays in darwin modules is silently ineffective

MULTIHOST follow-up, for the work Mac. Darwin passes `pkgs` both as an argument and a specialArg, so `nixpkgs.overlays` set in darwin modules does nothing; darwin fix overlays are hard-coded in mkDarwin. Move overlay ownership into `darwin/`.
