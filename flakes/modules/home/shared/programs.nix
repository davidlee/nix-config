{
  pkgs,
  lib,
  ...
}: {
  programs = {
    nix-search-tv.enableTelevisionIntegration = true;

    direnv = {
      enable = true;
      silent = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
      nix-direnv.enable = true;
    };

    yazi = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
      plugins = with pkgs.yaziPlugins; {
        lazygit.package = lazygit;
        jjui.package = jjui;
        glow.package = glow;
        wl-clipboard.package = wl-clipboard;
        # Plugins that don't call setup() can be configured in one line
        smart-enter.package = smart-enter;
        chmod.package = chmod;

        # Yatline-Catppuccin needs to be setup into a variable later
        yatline-catppuccin.package = yatline-catppuccin;

        yatline = {
          package = yatline;
          setup = true;
          settings = {
            tab_width = 20;
            # Return as lua code
            theme = lib.mkLuaInline ''
              require("yatline-catppuccin"):setup("mocha")
            '';
          };
        };
      };
      shellWrapperName = "y";
    };
  };
}
