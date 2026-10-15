# The feature tree: areas, in projection order. Each entry is
# { name = area; value = import ./<area>; }, and each area index lists its
# features the same way. See ../features.nix and README § Feature flags.
[
  {
    name = "hardware";
    value = import ./hardware;
  }
  {
    name = "session";
    value = import ./session;
  }
]
