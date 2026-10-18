jail-nix (`bind-nix-store-runtime-closure`) exposes only the store paths in the jail's own closure, not all of `/nix/store`. A binary built outside Nix on NixOS (e.g. `cargo install` → `~/.cargo/bin/doctrine`) is dynamically linked to specific store paths (glibc's `ld-linux`, gcc-lib via RUNPATH) that are in no jail closure.

Symptom: `command -v doctrine` finds it, but running it gives zsh's "command not found" (ENOENT from the missing ELF interpreter). Launcher-text tests don't catch it; run the binary in a real jail.

Fix in place: `elfClosureBinds` in `flakes/agents/jailed-agents.nix` reads the binary's interpreter + RUNPATH with patchelf, runs `nix-store -qR` on the host, and emits NUL-separated `--ro-bind-try p p` over `--args 23`. `hostDoctrine` (default on) uses it. Reuse it for any other host binary shared into a jail.

PATH in jail-nix is one raw word: use `"$HOME"/…`, not `~/…` (tilde only expands at word start), and not a literal `/home/david` (the tests forbid it).