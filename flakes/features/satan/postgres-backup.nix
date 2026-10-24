# Daily host-side PostgreSQL dump of the Oubliette assistant room.
{lib, ...}: {
  name = "postgres-backup";
  platforms = lib.platforms.linux;
  homeManager = {
    inputs,
    pkgs,
    config,
    ...
  }: let
    system = pkgs.stdenv.hostPlatform.system;
    roomClient = inputs.fleet.inputs.oubliette.packages.${system}.room-client-assistant;
    roomDoor = import ./room.nix config.home.homeDirectory;
    backup = pkgs.writeShellApplication {
      name = "satan-postgres-backup";
      runtimeInputs = [pkgs.coreutils pkgs.findutils pkgs.postgresql_18];
      text = builtins.readFile ./postgres-backup;
    };
  in {
    systemd.user.services.satan-postgres-backup = {
      Unit = {
        Description = "Back up the Oubliette assistant satan database";
        Documentation = "file:${config.home.homeDirectory}/flakes/SATAN.md";
      };
      Service = {
        Type = "oneshot";
        ExecStart = lib.getExe backup;
        Environment = [
          "HOME=%h"
          "XDG_RUNTIME_DIR=%t"
          "ROOM_CLIENT=${roomClient}"
          "ROOM_IDENTITY=${roomDoor.malebolge.identity}"
        ];
      };
    };

    systemd.user.timers.satan-postgres-backup = {
      Unit.Description = "Daily backup of the Oubliette assistant satan database";
      Timer = {
        OnCalendar = "*-*-* 03:00:00";
        Persistent = true;
      };
      Install.WantedBy = ["timers.target"];
    };
  };
}
