# IMP-073: DAW feature: pw-jack-wrapped Reaper, Ardour and Bitwig

<!-- Backlog item body — context, detail, links. The structured, queried fields
     live in the sister `backlog-NNN.toml`; this prose is free-form and is never
     structurally parsed (the storage rule). -->

## Intent

A selectable DAW feature on PipeWire's JACK emulation. Slice waived by the
user (2026-11-11); implemented directly.

## Shape

`features/audio/daw.nix` returns four records, appended to `features/audio.nix`:

- `audio.daw` — the plumbing: `pw-jack` (PipeWire's `jack` output), the
  `@users` rtprio limit and the `snd-seq`/`snd-rawmidi` modules, both moved
  from `pipewire.nix`. Sleipnir enables it, so the move changes nothing there.
- `audio.reaper`, `audio.ardour`, `audio.bitwig` — each `requires = ["audio.daw"]`
  and installs one DAW that links PipeWire's libjack in its own process.

Why per-process and not `services.pipewire.jack.enable`: nixpkgs (26.11)
deprecates that option, because it sets a session-wide `LD_LIBRARY_PATH`
(pipewire.nix module, the `warnings` and `sessionVariables` lines).

Two mechanisms, from the packaging:

- Ardour, Bitwig: a `symlinkJoin` wrapper prefixing `LD_LIBRARY_PATH`. Their
  libjack2 comes from RUNPATH, which `LD_LIBRARY_PATH` outranks.
- Reaper: `reaper.override { jackLibrary = pipewire.jack; }` — the package's
  own option (nixpkgs names `pipewire.jack` as the alternative). It goes into
  `runtimeDependencies`, i.e. RUNPATH, so no wrapper and no libjack2 at all.

The library comes from `config.services.pipewire.package.jack`, so it tracks
the running PipeWire.

## Latency

No fixed low-latency quantum: the user has no preference yet. The runtime
switch (`pw-metadata … clock.force-quantum`) and the per-app
`PIPEWIRE_QUANTUM` are documented in daw.nix's header. Revisit if a fixed
drop-in (`services.pipewire.extraConfig.pipewire."92-low-latency"`) is wanted.

## Dropped

`jackaudio` user group: the group does not exist on Sleipnir (IMP-003), and
it serves a real jackd, which PipeWire's JACK does not use. That was
IMP-003's last remaining group.

## Verification

- `testDawsRequireDaw` (features-test.nix): each DAW refused without
  `audio.daw`, accepted with it. Red before daw.nix existed, green after.
- `Sleipnir+off` coverage evaluates the three DAWs (off on Sleipnir).
- Built all three (2026-11-11). Ardour, Bitwig: every `bin/` wrapper prefixes
  `pipewire-1.6.11-jack/lib`; `.desktop` Exec lines are bare names (`ardour9`,
  `bitwig-studio`), so launchers hit the wrappers. Ardour's
  `libjack_audiobackend.so`: `ldd` resolves libjack to libjack2 plain, to
  PipeWire's with the wrapper's path. Reaper references `pipewire-…-jack` and
  no libjack2.
- Not yet run: launching a DAW against the live PipeWire graph.
