# IMP-001: Park shpool; emacs depends on zmx

shpool was stripped on the elisp side, replaced by zmx (no daemon). zmx is currently installed only by accident via the CLI package set.

- Park `modules/home/shared/shpool.nix` (comment out, per the parked convention).
- Remove `imports = [./shpool.nix]` from `modules/home/shared/emacs.nix`; make zmx an explicit emacs dependency.
- Side effect: darwin currently receives shpool's systemd user service through emacs.nix, contrary to the README ("skipping shpool.nix"). This fixes that too; update the README.
