# agents/doctrine.nix — where this host's Doctrine lives. Plain data: the
# NixOS env, the darwin home and the jail library import it; nothing copies it.
{
  # just install's root (cargo install --root ~/.local/share/doctrine), home-relative.
  installBinDir = ".local/share/doctrine/bin";
  # Where a jail sees a supplied Nix-built Doctrine: read-only, never on PATH.
  nixBinDir = "/run/doctrine-nix-bin";
}
