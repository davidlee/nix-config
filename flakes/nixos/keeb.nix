{
  pkgs,
  username,
  ...
}: {
  # allow non-root write access to firmware
  hardware = {
    keyboard.qmk.enable = true;
  };
}
