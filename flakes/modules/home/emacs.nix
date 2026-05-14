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
      extraEmacsPackages = epkgs: let
        # nixpkgs' emacs-application-framework derivation omits the
        # `reinput' Wayland focus-forwarder helper. EAF requires it
        # whenever Emacs runs natively on Wayland (Sway/Hyprland +
        # pgtk); without it the python side aborts with SIGABRT as
        # soon as a buffer takes focus.  See core/view.py around the
        # `current_desktop in ["sway","Hyprland"]' branch.
        eaf-with-reinput =
          (epkgs.emacs-application-framework.override {
            enabledApps = with epkgs; [
              eaf-browser
              eaf-pdf-viewer
              eaf-image-viewer
            ];
          }).overrideAttrs
          (old: {
            nativeBuildInputs = (old.nativeBuildInputs or []) ++ [pkgs.pkg-config];
            buildInputs =
              (old.buildInputs or [])
              ++ (with pkgs; [
                libinput
                libevdev
                udev
              ]);
            preBuild = ''
              ${old.preBuild or ""}
              # Upstream bug in reinput/main.c: it calls
              # `libinput_device_unref(dev)' on a device borrowed from
              # `libinput_event_get_device()'.  That function returns a
              # non-owning pointer, so the unref drops the refcount below
              # zero; libinput_unref(li) then walks freed memory and
              # SIGSEGVs in evdev_device_remove.  Strip the bogus unref.
              substituteInPlace reinput/main.c \
                --replace-fail $'\t\tlibinput_device_unref(dev);' ""
              echo "Compiling EAF reinput helper..."
              cc -O2 -o reinput/reinput reinput/main.c \
                $(pkg-config --cflags --libs libinput libevdev libudev) \
                -lpthread
            '';
            postInstall = ''
              ${old.postInstall or ""}
              LISPDIR=$(echo $out/share/emacs/site-lisp/elpa/eaf-*)
              install -Dm755 reinput/reinput "$LISPDIR/reinput/reinput"
            '';
          });
      in
        with epkgs; [
          meow
          meow-tree-sitter
          eaf-with-reinput
          # PREVIEW
          uniline
          ob-diagrams
          markdown-preview-mode
          treemacs
          ghostel
          kirigami
          org-modern
          dired-subtree
          dired-sidebar
          dired-toggle
          dired-list
          dired-collapse
          elfeed
          gptel
          s
          dash
          rainbow-mode
          telephone-line
          nerd-icons-dired
          hl-todo
          vterm-toggle
          ligature
          direnv
          envrc

          # project-treemacs
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
        enable = false;
        package = emacs;
      };
    };
  };
}
