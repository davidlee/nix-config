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
  {
    name = "non-nix-packages";
    value = import ./non-nix-packages.nix;
  }
  {
    name = "games";
    value = import ./games.nix;
  }
  {
    name = "ai";
    value = import ./ai.nix;
  }
  {
    name = "audio";
    value = import ./audio.nix;
  }
  {
    name = "services";
    value = import ./services.nix;
  }
  {
    name = "apps";
    value = import ./apps.nix;
  }
  {
    name = "desktop";
    value = import ./desktop.nix;
  }
  {
    name = "compositor";
    value = import ./compositor.nix;
  }
  {
    name = "shell";
    value = import ./shell.nix;
  }
]
