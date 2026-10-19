# The oubliette room `assistant`, as both doors reach it: the runner's
# (runner.nix, config.toml [door]) and the interactive daemon's
# (~/.config/malebolge/door.toml, DEC-079). Literals copied from the fleet
# (/srv/fleet/flake.nix rooms.assistant), which exposes no room data to
# home-manager (one source is satan IMP-044). Tests: ./room-test.nix.
#
# hostHome is this host's user's home (/home/david), where the keys live; the
# malebolge door's `home` is the room user's home, inside the room.
hostHome: rec {
  # What every door to the room shares.
  shared = rec {
    room = "assistant";
    # oubliette's, learnt by its push (accept-new); doors only read it.
    known_hosts = "/var/lib/capsule/room/${room}/known_hosts";
    # The name known_hosts records the room under (DEC-079).
    host_key_alias = "room-${room}";
  };

  # The interactive daemon's door (satan:SL-027 §4.3): exactly ROOM_DOOR_KEYS
  # plus `home`, or the daemon refuses it at start (DEC-079).
  malebolge =
    shared
    // {
      user = "satan"; # rooms.assistant.users.satan
      # Made by hand (ssh-keygen); its public half is in the fleet (POL-001).
      identity = "${hostHome}/.ssh/malebolge-vm.key";
      home = "/home/satan"; # the room user's, not hostHome
    };
}
