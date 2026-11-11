# DAWs on PipeWire's JACK (IMP-073). `daw` is the shared plumbing; each DAW
# requires it and links PipeWire's libjack in its own process only. Not
# services.pipewire.jack.enable: nixpkgs deprecates it, because it puts
# libjack on the whole session's LD_LIBRARY_PATH. Any other JACK app:
# `pw-jack <cmd>`.
#
# Latency: PipeWire's default quantum (buffer size, in frames) is left alone.
# For a low-latency session, force it at runtime and release it afterwards:
#
#   pw-metadata -n settings 0 clock.force-quantum 64   # ~1.3 ms at 48 kHz
#   pw-metadata -n settings 0 clock.force-quantum 0    # back to the default
#
# Or for one app only: `PIPEWIRE_QUANTUM=64/48000 ardour9`. Raise 64 to 128
# or 256 on xruns (clicks, dropouts). `pw-top` shows each node's quantum.
{lib}: let
  # LD_LIBRARY_PATH outranks the package's RUNPATH, so libjack resolves to
  # PipeWire's. Wraps every bin/ entry; .desktop files call them by name.
  withPwJack = pkgs: jack: pkg:
    pkgs.symlinkJoin {
      inherit (pkg) name meta;
      paths = [pkg];
      nativeBuildInputs = [pkgs.makeWrapper];
      postBuild = ''
        for f in "$out"/bin/*; do
          wrapProgram "$f" --prefix LD_LIBRARY_PATH : ${jack}/lib
        done
      '';
    };

  # name -> pkgs -> PipeWire libjack output -> the DAW package
  daws = {
    # Reaper's package takes the library as an option (patched into its
    # RUNPATH, no libjack2 at all), so it needs no wrapper.
    reaper = pkgs: jack: pkgs.reaper.override {jackLibrary = jack;};
    ardour = pkgs: jack: withPwJack pkgs jack pkgs.ardour;
    bitwig = pkgs: jack: withPwJack pkgs jack pkgs.bitwig-studio;
  };

  jackOf = config: config.services.pipewire.package.jack;
in
  [
    {
      name = "daw";
      nixos = {config, ...}: {
        environment.systemPackages = [(jackOf config)]; # pw-jack
        # ALSA sequencer and raw MIDI, for MIDI controllers.
        boot.kernelModules = ["snd-seq" "snd-rawmidi"];
        # Let user processes (DAW audio threads) request realtime priority.
        security.pam.loginLimits = [
          {
            domain = "@users";
            item = "rtprio";
            type = "-";
            value = 1;
          }
        ];
      };
    }
  ]
  ++ lib.mapAttrsToList (name: package: {
    inherit name;
    requires = ["audio.daw"];
    nixos = {
      config,
      pkgs,
      ...
    }: {
      environment.systemPackages = [(package pkgs (jackOf config))];
    };
  })
  daws
