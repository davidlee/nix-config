# goad — personal intervention shell.  A Slint window the host owns and a
# user-supplied backend drives; one JSON document per exchange over stdio,
# plus an ingress socket goad-emit writes to.  The host understands none of
# the domain — items, slots and the record format are backend.py's business.
#
# Source: ~/dev/goad (git+file:// input — a git input, never `path:`: the
# repo root holds a live unix socket nix refuses to copy, and only a git
# input carries the self.shortRev that `goad --version` prints).
#
# State + artefacts:
#   Config at ~/.config/goad/config.toml — the path `goad` with no argument
#   reads.  It names the backend command and the ingress socket.
#   Backend and its per-day records: ~/satan/goad/ (backend.py, data/).
#   ~/.config/goad/env belongs to the *cargo* install path (`just install`)
#   and is NOT read by this unit: the packaged binary is wrapped and carries
#   LD_LIBRARY_PATH and FONTCONFIG_FILE itself, so there is no second file
#   to drift against the build the unit runs.
#
# Replaces the hand-written unit at ~/satan/goad/goad.service.
#
# A refusal is exit 2 and the unit's RestartPreventExitStatus stops rather
# than loops; the diagnostic naming the configuration file is on stderr.
#
# Smoke:
#   systemctl --user status goad
#   journalctl --user -u goad -f
#   goad --version          # 0.1.0 (<rev>) — a bare 0.1.0 means a tarball
{
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.goad.homeManagerModules.default];

  services.goad = {
    enable = true;
    package = inputs.goad.packages.${pkgs.system}.goad;
  };
}
