# Outer profile for the user's own Macs (DEC-033): personal, plus whatever is
# Mac-only. Nothing of its own yet (goad on darwin is IMP-023), so a Mac keeps
# exactly the packages personal gives it.
{
  imports = [./personal.nix];
}
