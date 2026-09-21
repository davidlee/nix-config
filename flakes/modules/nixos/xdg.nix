{
  pkgs,
  lib,
  ...
}: let
  # Portal config lookup is first-file-wins: `<desktop>-portals.conf` shadows
  # `portals.conf` outright — there is no key-level merging between the two.
  # So a preference that should hold *everywhere* has to be written into every
  # desktop's own section; in `common` alone it stays inert in every session
  # that has a section of its own.
  #
  # We own `common`, `kde` and `sway` below. `niri` and `mango` define their
  # sections in their upstream flake modules and `umbriel` in ./umbriel.nix;
  # mkMerge adds the key to those without disturbing what they set.
  desktops = ["common" "kde" "niri" "sway" "mango" "umbriel"];

  # Plasma's file dialog (KIO/KFileWidget), not Dolphin — but it reads
  # ~/.local/share/user-places.xbel, so Dolphin's places and bookmarks carry
  # over. GTK apps get the Qt dialog too; that is the intent.
  kdeFileChooser =
    lib.genAttrs desktops
    (_: {"org.freedesktop.impl.portal.FileChooser" = ["kde"];});
in {
  xdg.portal = {
    enable = true;

    wlr = {
      enable = true;
      # xdpw's service PATH lacks /run/current-system/sw/bin, so its built-in
      # chooser chain (wmenu/wofi/rofi/...) all hit "command not found" and it
      # logs the misleading "no output found". Pin an absolute-path chooser.
      settings.screencast = {
        chooser_type = "dmenu";
        chooser_cmd = "${pkgs.fuzzel}/bin/fuzzel --dmenu --prompt='Share source: '";
        # Cap capture fps: Zoom's PipeWire consumer recycles the tiny dmabuf
        # pool too slowly for full-screen 4K at 60fps, starving it after ~2
        # frames ("out of buffers") → frozen share. 20fps keeps the pool fed
        # under heavy motion; 30 crashed Zoom, 20 is the tested ceiling.
        max_fps = 20;
      };
    };

    xdgOpenUsePortal = true;

    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
      kdePackages.xdg-desktop-portal-kde
    ];

    config = lib.mkMerge [
      kdeFileChooser
      {
        common = {
          default = ["wlr" "gtk" "gnome" "kde"];
          "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
          "org.freedesktop.impl.portal.ScreenCast" = "wlr";
          "org.freedesktop.impl.portal.Screenshot" = "wlr";
        };
        kde = {
          "org.freedesktop.impl.portal.Secret" = ["kwalletd6"];
        };
        sway = {
          default = ["gtk"];
          # wlr interfaces
          # Source: https://gitlab.archlinux.org/archlinux/packaging/packages/sway/-/commit/87acbcfcc8ea6a75e69ba7b0c976108d8e54855b
          "org.freedesktop.impl.portal.Inhibit" = "none";
        };
      }
    ];
  }; # XDG portal
}
