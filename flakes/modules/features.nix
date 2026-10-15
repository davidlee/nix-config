# Legacy feature flag declarations. Evaluated once by ../features.nix, outside
# the NixOS / darwin / home-manager module systems, and injected into all three
# as a plain attrset that hosts read to gate imports. Features migrated to the
# feature tree (../features) are selected by `feature.<area>.<name>.enable`
# instead, and have no flag here. See ../README.md#feature-flags.
#
# Defaults describe a host that says nothing. A host overrides what it likes in
# hosts/<hostname>/features.nix.
{lib, ...}: let
  inherit (lib) mkOption types;

  enabledByDefault = description:
    mkOption {
      inherit description;
      type = types.bool;
      default = true;
    };
in {
  options = {
    desktop = {
      sway = enabledByDefault "sway compositor, system and user halves";
      niri = enabledByDefault "niri compositor, system and user halves";
      cosmic = enabledByDefault "COSMIC desktop";
      kde = enabledByDefault "KDE Plasma";
      mango = enabledByDefault "mango compositor";
    };

    fonts = enabledByDefault "system font set";
  };
}
