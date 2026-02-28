_: {
  flake.homeModules.emacs = {pkgs, ...}: {
    home.packages = with pkgs; [
      emacs
    ];
  };
}
