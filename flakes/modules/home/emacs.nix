_: {
  flake.homeModules.emacs =
    {
      pkgs,
      inputs,
      username,
      ...
    }:
    let
      emacsDir = ../../../.emacs.d; # relative to repo root
      configDirs = [
        "core"
        "apps"
        "lang"
        "lisp"
        "editing"
        "completion"
        "org"
      ];
      elFilesIn =
        dir:
        let
          path = emacsDir + "/${dir}";
        in
        if builtins.pathExists path then
          map (f: path + "/${f}") (
            builtins.filter (f: builtins.match ".*\\.el" f != null) (builtins.attrNames (builtins.readDir path))
          )
        else
          [ ];
      allElFiles = builtins.concatLists (map elFilesIn configDirs);
      config = builtins.concatStringsSep "\n" (map builtins.readFile allElFiles);

      emacs = pkgs.emacsWithPackagesFromUsePackage {
        package = pkgs.emacs-unstable-pgtk;
        inherit config;
        alwaysEnsure = true;
      };
    in
    {
      nixpkgs.overlays = [ inputs.emacs-overlay.overlays.default ];

      home.packages = [
        emacs
        pkgs.emacsPackages.org-roam
        pkgs.emacsPackages.org-roam-ui
        pkgs.emacsPackages.org-roam-ql
        pkgs.emacsPackages.sqlite3
        pkgs.emacsclient-commands
        pkgs.sqlite
      ];

      services.emacs = {
        enable = true;
        package = emacs;
      };
    };
}
