# Satan features, in projection order: the harness, then the two daemons that
# need its postgres. Each is its own file. Shape: README § Feature tree.
{lib, ...}: [
  (import ./satan/harness.nix {inherit lib;})
  (import ./satan/patcher.nix {inherit lib;})
  (import ./satan/attrd.nix {inherit lib;})
]
