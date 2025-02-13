
{
  config,
  pkgs,
  # hy3,
  # inputs,
  lib,
  ...
}: {

  wayland.windowManager.sway = {
    enable = true;
    config = {
      modifier = "Mod4";
      terminal = "kitty";
      gaps = {
        smartGaps = true;
        smartBorders = "on";
        outer = 5;
        inner = 15;
      };

      bars = [{
        command = "waybar";
      }];

      # TODO maybe we want to use lib.attrsets.mergeAttrsList like in https://lafreniere.xyz/docs/nix-home-manager-sway.html
      keybindings =
      let
        modifier = config.wayland.windowManager.sway.config.modifier;
      in lib.mkOptionDefault { # override not replace defaults
        "${modifier}+n" = "scratchpad show";
        "${modifier}+Shift+n" = "move scratchpad";
        "${modifier}+t" = "layout tabbed";
        "${modifier}+space" = "exec fuzzel";
        
        # replace floating window binds we stomped with launcher binds on space
        "${modifier}+l" = "focus mode_toggle";
        "${modifier}+Shift+l" = "floating toggle";
      };
    };
    # swaynag.enable = false;
    extraOptions = [ "--unsupported-gpu" ];
  };

  ## TODO swaybar
}
