# Audio features, in projection order. Shape: README § Feature tree.
{lib, ...}: [
  (import ./audio/pipewire.nix)
  (import ./audio/mpd.nix)
  (import ./audio/speech.nix)
  (import ./audio/dictate.nix)
  (import ./audio/alarm.nix {inherit lib;})
]
