# Satan features, in projection order: the harness, the two daemons that need
# its postgres, then the patch-job runner (malebolge). Each is its own file.
# Shape: README § Feature tree.
{lib, ...}: [
  (import ./satan/harness.nix {inherit lib;})
  (import ./satan/patcher.nix {inherit lib;})
  (import ./satan/attrd.nix {inherit lib;})
  (import ./satan/runner.nix {inherit lib;})
]
