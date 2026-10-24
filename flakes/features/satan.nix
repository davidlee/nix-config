# Satan features, in projection order: the harness, the daemon that needs
# its postgres (attrd), the patch-job runner (malebolge), then the on-demand
# interactive daemon (malebolge-room). Each is its own file.
# Shape: README § Feature tree.
{lib, ...}: [
  (import ./satan/harness.nix {inherit lib;})
  (import ./satan/attrd.nix {inherit lib;})
  (import ./satan/runner.nix {inherit lib;})
  (import ./satan/malebolge.nix {inherit lib;})
  (import ./satan/postgres-backup.nix {inherit lib;})
]
