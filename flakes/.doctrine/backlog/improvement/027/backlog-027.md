# IMP-027: dev.build installs clangStdenv (a stdenv) and binutils as home packages

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

`dev.build` (`features/dev.nix`, the `available pkgs [ … ]` list) puts
`clangStdenv` and `binutils` into `home.packages`. `clangStdenv` is a stdenv,
not a tool; on Linux it was a pre-existing oddity, moved verbatim by SL-008
PHASE-04. Since PHASE-07's availability filter it also lands on Draupnir as
`stdenv-darwin`, and `binutils` as `binutils-wrapper` (cctools), which may
shadow or collide with the system `ld`/`ar`/`nm`/… (see CHR-015, SL-008
VH-2). Found in SL-008 PHASE-07 notes; RV-018.

Fix: drop `clangStdenv` (use `clang`/`clang-tools` if a compiler is wanted);
decide whether `binutils` belongs on darwin (brokenOn, or a Linux-only list).
Gate: Sleipnir link maps; Draupnir drvs-sets delta listed.
