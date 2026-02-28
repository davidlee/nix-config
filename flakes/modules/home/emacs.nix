_: {
  flake.homeModules.emacs = {pkgs, ...}: {
    home.packages = with pkgs; [
      emacsclient-commands
      emacs-nox
    ];
  };
}
