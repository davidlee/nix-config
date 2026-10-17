# Outer profile for the user's own Macs (DEC-033): personal, plus whatever is
# Mac-only. Nothing of its own yet (goad on darwin is IMP-023). The cli
# features it selects give a Mac the packages available on aarch64-darwin,
# minus features/platform-skips.nix (DEC-036).
{
  imports = [./personal.nix];
}
