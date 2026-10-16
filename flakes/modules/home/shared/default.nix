# Temporary: the editors and EDITOR/VISUAL, imported by the home base until
# SL-008 P4 turns them into editor.* features and dissolves this directory.
{...}: {
  imports = [
    ./emacs.nix
    ./nvim.nix
    ./nvim-plugins.nix
  ];
  home.sessionVariables = {
    EDITOR = "emacsclient -c";
    VISUAL = "emacsclient -c";
  };
}
