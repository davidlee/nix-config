# Sleipnir's feature selection: the profiles it imports, and the legacy flags
# it overrides (defaults in ../../modules/features.nix). Anything not named
# here takes the default.
{
  imports = [../../features/profiles/workstation.nix];

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
