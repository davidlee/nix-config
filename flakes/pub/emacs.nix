{pkgs}: let
  emacsPackage =
    if pkgs.stdenv.isDarwin
    then pkgs.emacs-macport
    else pkgs.emacs-unstable-pgtk;

  emacsPackages = pkgs.emacsPackagesFor emacsPackage;
in
  emacsPackages.emacsWithPackages (epkgs: let
    # # EAF embeds X11/Wayland GUI apps; it is Linux-only (its build
    # # pulls libinput/libevdev/udev). Skip it entirely on Darwin.
    # #
    # # nixpkgs' emacs-application-framework derivation omits the
    # # `reinput' Wayland focus-forwarder helper. EAF requires it
    # # whenever Emacs runs natively on Wayland (Sway/Hyprland +
    # # pgtk); without it the python side aborts with SIGABRT as
    # # soon as a buffer takes focus.  See core/view.py around the
    # # `current_desktop in ["sway","Hyprland"]' branch.
    # eaf-with-reinput =
    #   (epkgs.emacs-application-framework.override {
    #     enabledApps = with epkgs; [
    #       eaf-browser
    #       eaf-pdf-viewer
    #       eaf-image-viewer
    #     ];
    #   }).overrideAttrs
    #   (old: {
    #     nativeBuildInputs = (old.nativeBuildInputs or []) ++ [pkgs.pkg-config];
    #     buildInputs =
    #       (old.buildInputs or [])
    #       ++ (with pkgs; [
    #         libinput
    #         libevdev
    #         udev
    #       ]);
    #     preBuild = ''
    #       ${old.preBuild or ""}
    #       # Upstream bug in reinput/main.c: it calls
    #       # `libinput_device_unref(dev)' on a device borrowed from
    #       # `libinput_event_get_device()'.  That function returns a
    #       # non-owning pointer, so the unref drops the refcount below
    #       # zero; libinput_unref(li) then walks freed memory and
    #       # SIGSEGVs in evdev_device_remove.  Strip the bogus unref.
    #       substituteInPlace reinput/main.c \
    #         --replace-fail $'\t\tlibinput_device_unref(dev);' ""
    #       echo "Compiling EAF reinput helper..."
    #       cc -O2 -o reinput/reinput reinput/main.c \
    #         $(pkg-config --cflags --libs libinput libevdev libudev) \
    #         -lpthread
    #     '';
    #     postInstall = ''
    #       ${old.postInstall or ""}
    #       LISPDIR=$(echo $out/share/emacs/site-lisp/elpa/eaf-*)
    #       install -Dm755 reinput/reinput "$LISPDIR/reinput/reinput"
    #     '';
    #   });
  in
    # Packages Emacs' own `package-vc` mechanism installs at runtime
    # (declared in custom-vars.el's `package-vc-selected-packages`),
    # NOT managed here: eaf, ghostel, lambda-line, claude-code-ide,
    # combobulate, nano/nano-emacs, eca, and others with a `:vc`
    # use-package stanza. Nix has no store path for these; they live
    # under ~/.emacs.d/elpa and must stay writable.
    with epkgs;
      [
        ace-window
        agent-shell
        aggressive-indent
        apheleia
        atomic-chrome
        avy
        beacon
        breadcrumb
        buffer-terminator
        cape
        comment-dwim-2
        compile-angel
        consult
        consult-eglot
        consult-notes
        copy-as-format
        corfu
        crux
        dash
        deadgrep
        denote
        denote-explore
        diminish
        dired-collapse
        dired-list
        dired-sidebar
        dired-subtree
        dired-toggle
        diredfl
        direnv
        dirvish
        doom-themes
        dumb-jump
        dwim-shell-command
        eat
        editorconfig
        elfeed
        elisp-demos
        embark
        embark-consult
        envrc
        eros
        expand-region
        expreg
        git-link
        git-modes
        go-mode
        goto-chg
        gptel
        grip-mode
        helpful
        highlight-defined
        highlight-numbers
        highlight-quoted
        hl-todo
        hydra
        iedit
        jinx
        json-mode
        kind-icon
        kirigami
        leaf
        ligature
        magit
        marginalia
        markdown-mode
        markdown-preview-mode
        markdown-toc
        meow
        meow-tree-sitter
        minuet
        move-text
        multiple-cursors
        nano-agenda
        nano-modeline
        nano-theme
        nerd-icons
        nerd-icons-completion
        nerd-icons-dired
        nix-mode
        olivetti
        orderless
        org-bullets
        org-gcal
        org-modern
        org-ql
        org-roam
        outline-indent
        package-lint
        package-lint-flymake
        persp-mode
        popper
        posframe
        prescient
        puni
        rainbow-delimiters
        rainbow-mode
        ready-player
        rg
        s
        shackle
        smudge
        solaire-mode
        spacious-padding
        suggest
        super-save
        telephone-line
        tempel
        transient
        transpose-frame
        treemacs
        treesit-auto
        treesit-fold
        undo-fu
        undo-fu-session
        vertico
        vertico-prescient
        visual-regexp-steroids
        vterm-toggle
        vundo
        wgrep
        ws-butler
        yaml-mode
        zoom-window
      ]
      ++ pkgs.lib.optionals (!pkgs.stdenv.isDarwin) [
        #eaf-with-reinput
      ])
