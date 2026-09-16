{
  lib,
  features,
  ...
}: {
  config = lib.mkIf features.games {
    programs = {
      # lutris.enable = true;
      mangohud.enable = true;
    };
  };
}
