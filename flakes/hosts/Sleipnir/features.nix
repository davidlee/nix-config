# Sleipnir's feature flags, overriding the defaults declared in
# ../../modules/features.nix. Anything not named here takes the default.
{
  games.enable = true;

  desktop = {
    sway = true;
    niri = true;
    cosmic = true;
    kde = true;
    mango = true;
  };

  ai = {
    llama-cpp = false;
    rocm = false;
  };
  hardware = {
    openrgb = false;
    ssd = true;
    microcode = true;
  };
  virt = {
    qemu = true;
    docker = true;
  };
  apps = {
    appimage = true;
    flatpak = true;
    cad = true;
  };
  fonts = true;
  printing = true;
  speech = false;
  mpd = true;
  sunshine = false;
  webserver = true;

  # games.enable = true;
}
