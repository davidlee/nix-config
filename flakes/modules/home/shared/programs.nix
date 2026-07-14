{pkgs, ...}: {
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
      };
      shellWrapperName = "y";
    };
  };
}
