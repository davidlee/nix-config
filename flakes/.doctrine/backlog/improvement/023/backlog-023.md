# IMP-023: goad on darwin: launchd agent and a Mac-fetchable input

`personal` covers both machines the user owns, Sleipnir and Draupnir
(user, 2026-10-16, SL-008 scoping). goad should work on darwin, but two
things block it:

- goad's home-manager module (`~/dev/goad/nix/module.nix`, in goad's own
  repo) only writes `systemd.user.services.goad`. darwin needs a
  `launchd.agents` equivalent, either upstream or as a darwin half of the
  goad feature here.
- The input is `git+file:///home/david/dev/goad`. The Mac's home is
  `/Users/david`, and it has no `~/dev` checkouts yet. Needs ISS-006 (lock
  pins local paths) and IDE-002 (per-host local overrides) or a remote URL.

SL-008 (W5) leaves room for a darwin half and does not build it.
