_: {
  flake.homeModules.emacs = {
    pkgs,
    inputs,
    username,
    self,
    ...
  }: let
    emacsDir = ../../../.emacs.d; # relative to repo root
    configDirs = [
      "core"
      "apps"
      "lang"
      "lisp"
      "editing"
      "completion"
      "org"
      "dev"
    ];
    elFilesIn = dir: let
      path = emacsDir + "/${dir}";
    in
      if builtins.pathExists path
      then
        map (f: path + "/${f}") (
          builtins.filter (f: builtins.match ".*\\.el" f != null) (builtins.attrNames (builtins.readDir path))
        )
      else [];
    allElFiles = builtins.concatLists (map elFilesIn configDirs);
    config = builtins.concatStringsSep "\n" (map builtins.readFile allElFiles);

    emacsPackage =
      if pkgs.stdenv.isDarwin
      then pkgs.emacs-macport
      else pkgs.emacs-unstable-pgtk;
    emacs = pkgs.emacsWithPackagesFromUsePackage {
      package = emacsPackage;
      inherit config;
      alwaysEnsure = true;
      alwaysTangle = true;
      extraEmacsPackages = epkgs:
        with epkgs; [
          meow
          meow-tree-sitter

          # use-package
          # undo-fu
          # undo-fu-session
          # eat
          # git-modes
          # yaml-mode
          # json-mode
          # go-mode
        ];
    };
  in {
    imports = [self.homeModules.shpool];

    home.packages = [
      emacs
      pkgs.emacsclient-commands
      pkgs.dict # testing dictd
      # pkgs.emacsPackages.treesit-auto
    ];

    services = {
      emacs = {
        # client.enable = true;
        enable = true;
        package = emacs;
      };
    };
  };
}
