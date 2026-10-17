# The pin filter workarounds/check applies to flake.workaroundProbes with
# `nix eval --apply`, and probes-test.nix forces: one text, two readers.
# It must select probes by `pin` alone, so a probe on the other pin is never
# resolved and its storePath never forced (RV-025 F-3). null keeps every
# probe.
pin: probes:
if pin == null
then probes
else builtins.filter (p: p.pin == pin) probes
