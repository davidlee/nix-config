# The feature tree: areas, in projection order. Each entry is
# { name = area; value = import ./<area>.nix; }; each area file lists its
# features, each a self-named record. See ../features.nix and README § Feature
# tree.
[
  {
    name = "hardware";
    value = import ./hardware.nix;
  }
  {
    name = "session";
    value = import ./session.nix;
  }
  {
    name = "virt";
    value = import ./virt.nix;
  }
]
