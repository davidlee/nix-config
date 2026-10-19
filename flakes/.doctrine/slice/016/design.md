<!-- doctrine:section sec-1 -->
## Overview

malebolge's interactive daemon, in satan:SL-027's room profile, reaches oubliette
room `assistant` through a door file named by `MALEBOLGE_DOOR`. This slice
renders it, from the same room data as the runner's `[door]`. Decision: DEC-079
(path, schema, alias, owner).

```
features/satan/room.nix   plain data, hostHome -> { shared; malebolge }
   │ import                                  │ import
   ▼                                         ▼
features/satan/runner.nix                  features/satan/room-test.nix
  door = shared // runner keys               lib.runTests ──> checks.satan-room
     └─> ~/.config/satan-runner/config.toml  (unchanged)
  { door = malebolge; }
     └─> ~/.config/malebolge/door.toml       (new, stable path)
              │ read-only bind, MALEBOLGE_DOOR (satan:SL-027)
              ▼
         daemon: onlyKeys([...ROOM_DOOR_KEYS, "home"]) → readRoomDoor
```
<!-- doctrine:section sec-2 -->
## Room data (`features/satan/room.nix`)

Plain data, a function of the host user's home only. The argument is
`hostHome` (`/home/david`), not `home`: the malebolge door also has a `home`
key, which is the room user's home (`/home/satan`). The two must not be read as
one.

```nix
# The oubliette room `assistant`, as both doors reach it. Literals copied from
# the fleet (/srv/fleet/flake.nix rooms.assistant), which exposes no room data
# to home-manager (one source is satan IMP-044).
hostHome: rec {
  # What every door to the room shares.
  shared = rec {
    room = "assistant";
    # oubliette's, learnt by its push (accept-new); doors only read it.
    known_hosts = "/var/lib/capsule/room/${room}/known_hosts";
    # The name known_hosts records the room under (DEC-079).
    host_key_alias = "room-${room}";
  };
  # The interactive daemon's door (satan:SL-027 §4.3): exactly
  # ROOM_DOOR_KEYS + home, or the daemon refuses it at start (DEC-079).
  malebolge =
    shared
    // {
      user = "satan"; # rooms.assistant.users.satan
      # Made by hand (ssh-keygen); its public half is the fleet's (POL-001).
      identity = "${hostHome}/.ssh/malebolge-vm.key";
      home = "/home/satan"; # the room user's home, not hostHome
    };
}
```

`socket` (`/run/capsule-room/${room}/ssh.sock`) stays in `runner.nix`: only the
runner's ssh_config uses it. The final comment wording is the implementer's;
the shape and names are fixed here.
<!-- doctrine:section sec-3 -->
## Render (`features/satan/runner.nix`)

```nix
roomDoor = import ./room.nix home;
inherit (roomDoor.shared) room;      # was the literal; socket and quarantine keep `${room}`

door = roomDoor.shared // {
  kind = "room";
  user = roomUser;                    # "agent"
  identity = "${home}/.ssh/malebolge.key";
  session_path = "/run/current-system/sw/bin/session";
  ssh_config = "${configDir}/ssh_config";
};

xdg.configFile."malebolge/door.toml".source =
  (pkgs.formats.toml {}).generate "malebolge-door.toml" {door = roomDoor.malebolge;};
```

`pkgs.formats.toml` serialises attrsets in sorted key order, so the runner's
`door`, built from the same values, renders byte-identical. The comments that
sat on `known_hosts` and `host_key_alias` move to `room.nix` with them. The
file's Files header gains the `door.toml` line, and the existing
`gateway-models.json` line keeps its wording.
<!-- doctrine:section sec-4 -->
## Test (`features/satan/room-test.nix`) and `evalTests`

`room-test.nix` takes `lib` and returns `lib.runTests` failures, like
`features-test.nix` and `host-meta-test.nix`. It imports `room.nix` with a
fixture home (`room = import ./room.nix "/home/fixture"`), so it shows that `hostHome` reaches `identity`
and nothing else:

| test | expects |
|---|---|
| `testMalebolgeKeys` | `attrNames room.malebolge` = sorted `ROOM_DOOR_KEYS ++ ["home"]`. `ROOM_DOOR_KEYS` is a hand-copied literal with a pointer to `malebolge/src/room/door.ts` (DEC-079: this is the schema) |
| `testSharedCarried` | `intersectAttrs room.shared room.malebolge == room.shared` |
| `testHostHome` | `identity` is under `/home/fixture`; `home` is `/home/satan` |
| `testAlias` | `host_key_alias == "room-assistant"`, `known_hosts` under `/var/lib/capsule/room/assistant/` |

The runner's side, "the runner's door carries the shared facts", follows from
`runner.nix` building `door` as `roomDoor.shared // …` with no key overlap. That
cannot be tested without evaluating a home, and is checked by inq-5's store-path
comparison instead.

**`evalTests` (refactor).** `perSystem.nix` gains one local helper and uses it
three times:

```nix
# A test file (lib -> lib.runTests failures) as a check: evaluating it is the
# test; the build is a stub named for the file.
evalTests = file: let
  name = lib.removeSuffix ".nix" (baseNameOf file);
  failures = import file lib;
in
  if failures == []
  then pkgs.runCommand name {} "touch $out"
  else throw "${name}.nix failed:\n${lib.generators.toPretty {} failures}";

checks = {
  features = evalTests ./features-test.nix;
  host-meta = evalTests ./host-meta-test.nix;
} // lib.optionalAttrs isLinux {
  satan-room = evalTests ./features/satan/room-test.nix;
  llm-gateway = …;   # unchanged
};
```

The name comes from the file, so the stub drv and the throw message name the
real file (`features-test`, `host-meta-test`, `room-test`). The existing
checks' drvs and messages are unchanged. A `name` argument would have made
`satan-room` report a nonexistent `satan-room-test.nix` (RV-035 F-1). `workarounds/probes.nix` keeps its own copy: it is another flake module
and its test takes more arguments (IMP-031).

`just test` gains `nix build ".#checks.$(nix config show system).satan-room"`
inside the Linux guard, beside `llm-gateway`.
<!-- doctrine:section sec-5 -->
## Code impact

| file | change |
|---|---|
| `features/satan/room.nix` | new: room data (sec-2) |
| `features/satan/room-test.nix` | new: tests (sec-4) |
| `features/satan/runner.nix` | import room data, build `door` from it, render `door.toml`, Files header (sec-3) |
| `perSystem.nix` | `evalTests`; `features`, `host-meta` use it; `satan-room` check (sec-4) |
| `justfile` | `test`: build `checks.<system>.satan-room` (Linux) |
| `SATAN.md` | file table: a `door.toml` row (the daemon's door, rendered from `room.nix`) |

New files must be `git add`ed explicitly: the flake sees only tracked files.
<!-- doctrine:section sec-6 -->
## Verification

| criterion | how |
|---|---|
| Room-data tests pass, and fail when the data breaks | `just test`. Red first: write `room-test.nix` against a stub `room.nix` that has the keys with wrong values, both `git add -N`ed; an absent or empty file fails on an eval error, not on the assertions (RV-035 F-2). Before keeping it, make sure a stray key (e.g. `ssh_config`) added to `malebolge` fails `testMalebolgeKeys` |
| Runner `config.toml` unchanged | `nix eval --raw '.#homeConfigurations."david@Sleipnir".config.xdg.configFile."satan-runner/config.toml".source.outPath'` (with the justfile's local overrides) gives the same path before and after |
| `evalTests` refactor is neutral | `checks.<system>.features` and `checks.<system>.host-meta` keep their drvPaths before and after |
| Door file content | after the change, build `…xdg.configFile."malebolge/door.toml".source` and read it: one `[door]` table, six keys, values as in sec-2 |
| Gate | `just gate` green (tests + treefmt: alejandra, statix, deadnix) |
| Live (VH, after `just home-switch`) | `~/.config/malebolge/door.toml` exists, with the content above |
| Handoff (VA) | at close, with the user's OK: satan:SL-027 told the path, schema (DEC-079), alias correction and owner |
