_: {
  # Without a KDE platform theme plugin, Qt hands every app a default light
  # palette and never reads ~/.config/kdeglobals — so the colour scheme there is
  # inert. Dolphin looked like an exception only because it applies its own
  # per-app override (`dolphinrc [UiSettings] ColorScheme`) via
  # KColorSchemeManager; the xdg-desktop-portal-kde file dialog has no such
  # override and rendered light.
  #
  # `platformTheme = "kde"` installs kdePackages.{plasma-integration, kio,
  # systemsettings} and sets QT_QPA_PLATFORMTHEME + QT_PLUGIN_PATH, which is
  # what makes kdeglobals authoritative for every Qt app.
  qt = {
    enable = true;
    platformTheme = "kde";
    style = "breeze";
  };
}
