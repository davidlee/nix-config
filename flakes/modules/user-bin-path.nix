# modules/user-bin-path.nix — user bin directories whose order matters,
# home-relative. pam (Linux) and home-manager (darwin) prepend them; shells only append.
let
  doctrine = import ../agents/doctrine.nix;
in [
  doctrine.installBinDir
  ".local/bin"
  ".local/bin/scripts"
  ".cargo/bin"
  "go/bin"
  ".pnpm-global/bin"
  ".npm-global/bin"
]
