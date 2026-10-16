# Draupnir's feature selection: personal-darwin, which adds nothing to
# personal yet. The Mac gets the cli packages available on aarch64-darwin,
# minus features/cli-broken.nix (DEC-036).
{
  imports = [../../features/profiles/personal-darwin.nix];
}
