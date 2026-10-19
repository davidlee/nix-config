# Tests for ./room.nix, the room data both doors are built from.
# `lib.runTests` returns [] when every test passes; perSystem.nix runs this as
# checks.<system>.satan-room (`just test`).
lib: let
  room = import ./room.nix "/home/fixture";

  # The interactive daemon's parser keys: satan:SL-027's ROOM_DOOR_KEYS
  # (malebolge src/room/door.ts), hand-copied, plus `home`. The daemon refuses
  # any other key, so this list is the door file's schema (DEC-079).
  ROOM_DOOR_KEYS = ["room" "user" "known_hosts" "host_key_alias" "identity"];
in
  lib.runTests {
    testMalebolgeKeys = {
      expr = lib.attrNames room.malebolge;
      expected = lib.sort lib.lessThan (ROOM_DOOR_KEYS ++ ["home"]);
    };

    # The runner's door is room.shared plus its own keys (runner.nix).
    testSharedCarried = {
      expr = builtins.intersectAttrs room.shared room.malebolge;
      expected = room.shared;
    };

    # hostHome reaches the key path only; `home` is the room user's.
    testHostHome = {
      expr = {inherit (room.malebolge) identity home;};
      expected = {
        identity = "/home/fixture/.ssh/malebolge-vm.key";
        home = "/home/satan";
      };
    };

    # The name the room's known_hosts records it under (DEC-079).
    testAlias = {
      expr = room.shared;
      expected = {
        room = "assistant";
        known_hosts = "/var/lib/capsule/room/assistant/known_hosts";
        host_key_alias = "room-assistant";
      };
    };
  }
