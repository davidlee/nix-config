# malebolge-room — SATAN's interactive daemon, room profile (satan SL-028 §4.1).
# On demand: no Install, so nothing starts it at login or on switch;
# `M-x malebolge-start` / `malebolge-stop` (~/dev/malebolge/emacs/malebolge.el)
# drive it through systemctl.
#
# Source: the satan input's legacyPackages.mkJailedMalebolge, which runs the
# **live tree** ~/dev/malebolge, not a pin (RSK-020; contrast ./runner.nix).
# Its mail toolset reads through screwtape, so it needs ./screwtape.nix: the
# launcher binds that module's package, config and store dir (malebolge
# SL-005).
# X-RestartIfChanged=false: a switch never kills a live conversation, so a
# changed wrapper or live tree takes effect only on
#   systemctl --user restart malebolge-room
#
# Logs: journalctl --user -u malebolge-room -f
{lib, ...}: {
  name = "malebolge";
  platforms = lib.platforms.linux;
  homeManager = {
    inputs,
    pkgs,
    config,
    ...
  }: let
    home = config.home.homeDirectory;
    jailed = inputs.satan.legacyPackages.${pkgs.stdenv.hostPlatform.system}.mkJailedMalebolge {
      screwtape = {inherit (config.services.screwtape) package configFile storeDir;};
      # The bookmark tools' source (malebolge SL-008, CHR-006): the default
      # profile's bookmarkbackups directory, bound read-only by the launcher.
      bookmarkBackups = "${home}/.config/mozilla/firefox/ez06zp0k.default/bookmarkbackups";
    };
  in {
    assertions = [
      {
        assertion = config.services.screwtape.enable;
        message = "feature.satan.malebolge: the room daemon's mail tools need feature.satan.screwtape.";
      }
    ];

    systemd.user.services.malebolge-room = {
      Unit = {
        Description = "SATAN interactive daemon, room profile (malebolge)";
        Documentation = "file:${home}/flakes/SATAN.md";
        StartLimitIntervalSec = 300;
        StartLimitBurst = 5;
        # As home-manager's emacs.nix: a switch must not restart it.
        X-RestartIfChanged = false;
      };
      Service = {
        ExecStart = lib.getExe' jailed "jailed-malebolge";
        Restart = "on-failure";
        RestartSec = 10;
        Environment = ["HOME=%h" "XDG_RUNTIME_DIR=%t"];
      };
    };
  };
}
