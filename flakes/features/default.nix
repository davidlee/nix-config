# The feature tree: areas, in projection order. Maps each written area name to
# { name = area; value = import ./<area>.nix {inherit lib;}; }; each area file
# lists its features, each a self-named record. See ../features.nix and README
# § Feature tree.
{lib}: let
  area = name: {
    inherit name;
    value = import ./${name}.nix {inherit lib;};
  };
in
  map area ["hardware" "session" "virt" "non-nix-packages" "games" "ai" "agents" "audio" "services" "desktop" "compositor" "shell" "editor" "notes" "dev" "docs" "data" "files" "net" "web" "system" "text" "office" "security" "media" "graphics" "comms" "fun" "terminal" "attention" "satan"]
