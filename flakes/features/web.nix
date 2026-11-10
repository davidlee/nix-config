# Web features, in projection order. Shape: README § Feature tree.
{lib, ...}: [
  {
    name = "browsers";
    platforms = lib.platforms.linux;
    homeManager = {
      pkgs,
      config,
      inputs,
      ...
    }: let
      foxmacs = inputs.foxmacs.packages.${pkgs.stdenv.hostPlatform.system};
      # globalExtensions installs by addonId, which foxmacs' packages lack.
      withAddonId = addonId: pkg:
        pkg.overrideAttrs (old: {passthru = (old.passthru or {}) // {inherit addonId;};});
    in {
      home.packages = with pkgs; [
        # (callPackage ../../../packages/helium.nix {})
        # ladybird
        vivaldi
        ungoogled-chromium
        epiphany
      ];

      programs = {
        firefox = {
          enable = true;
          # Developer Edition: the only branded build that installs unsigned
          # extensions, which foxmacs' are (IDE-005).
          package = pkgs.firefox-devedition.override {
            extraPrefs = ''
              pref("xpinstall.signatures.required", false);
              // EWM shows one Firefox window per Emacs buffer: links open
              // windows, not tabs (foxmacs' firefox/prefs.json).
              pref("browser.link.open_newwindow", 2);
              pref("browser.link.open_newwindow.restriction", 0);
              pref("browser.link.open_newwindow.override.external", 2);
              pref("browser.tabs.opentabfor.middleclick", false);
            '';
          };
          nativeMessagingHosts = [foxmacs.foxmacs-host];
          globalExtensions = [
            (withAddonId "foxmacs@blad.is" foxmacs.foxmacs-extension)
            (withAddonId "tabs-to-windows@blad.is" foxmacs.tabs-to-windows)
          ];
          # nativeMessagingHosts.packages = [pkgs.firefoxpwa];
        };
        firefoxpwa.enable = true;
        firefox.configPath = "${config.xdg.configHome}/mozilla/firefox";

        librewolf = {
          enable = true;
        };
      };
    };
  }

  {
    name = "terminal";
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        ddgr # search duckduckgo
        w3m-full
        browsh
        lynx
      ];
    };
  }
]
