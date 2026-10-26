# IMP-049: W7 — malebolge owns its daemon package and jail; satan consumes them

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

Programme W7. malebolge has its own flake (jails for working on it, and the
`satan-runner` package), but satan builds and confines the malebolge
**daemon** from the live checkout (`satan/flake.nix` ~L234–294
`malebolgeDaemon` / `malebolgeRoomJailOptions`, ~L451–465 `jailed-malebolge`,
plus jail-probe checks), and satan's dev jails mount malebolge rw. Agents have
been working on malebolge from satan's jail.

Want: malebolge's flake owns the daemon package and its jail; satan consumes
them as an input. Target to confirm with the user at slice.

After satan's in-flight flake work (2026-10-27) and its W5 migration.
