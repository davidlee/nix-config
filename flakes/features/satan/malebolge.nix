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

    # A dedicated socket-activated helper runs the fixed host recipe. The
    # client sends no command or arguments; socket access is the capability.
    systemd.user.sockets.room-behind = {
      Unit.Description = "Room checkout divergence socket";
      Socket = {
        ListenStream = "%t/room-behind/room-behind.sock";
        SocketMode = "0600";
        DirectoryMode = "0700";
        Accept = true;
      };
      Install.WantedBy = ["sockets.target"];
    };
    systemd.user.services."room-behind@" = {
      Unit.Description = "Room checkout divergence query";
      Service = {
        ExecStart = "${pkgs.nodejs_latest}/bin/node ${home}/dev/malebolge/src/room-behind-host.ts";
        StandardInput = "socket";
        StandardOutput = "socket";
        StandardError = "journal";
        Environment = ["PATH=${lib.makeBinPath [pkgs.just pkgs.bash pkgs.git pkgs.jq pkgs.coreutils]}:/run/current-system/sw/bin"];
        TimeoutStartSec = 40;
      };
    };

    # A separate fixed-command endpoint keeps the mutating capability explicit.
    systemd.user.sockets.sync-room = {
      Unit.Description = "Room synchronization socket";
      Socket = {
        ListenStream = "%t/room-behind/sync-room.sock";
        SocketMode = "0600";
        DirectoryMode = "0700";
        Accept = true;
      };
      Install.WantedBy = ["sockets.target"];
    };
    systemd.user.services."sync-room@" = {
      Unit.Description = "Synchronize room checkouts";
      Service = {
        ExecStart = "${pkgs.nodejs_latest}/bin/node ${home}/dev/malebolge/src/room-behind-host.ts sync-room";
        StandardInput = "socket";
        StandardOutput = "socket";
        StandardError = "journal";
        Environment = ["PATH=${lib.makeBinPath [pkgs.just pkgs.bash pkgs.git pkgs.jq pkgs.coreutils pkgs.util-linux]}:/run/current-system/sw/bin"];
        RuntimeMaxSec = 305;
      };
    };

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
        # Jev's credential for the mail tools' classify (malebolge DEC-059,
        # IMP-055): decrypted host-side into $CREDENTIALS_DIRECTORY, which
        # the launcher binds read-only into the jail (satan IMP-060).
        LoadCredentialEncrypted = "jev:%h/.config/credstore.encrypted/screwtape.jev";
      };
    };
  };
}
