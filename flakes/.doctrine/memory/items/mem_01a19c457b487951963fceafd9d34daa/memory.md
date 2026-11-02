Measured 2026-11-02 (SL-022 PHASE-01) by building a stub jail and reading it.

`mkJailedPi { gateway = …; }` returns
`gatewayJail.wrap inner` (`agents/gateway-jail.nix`), a 16-line
`writeShellScriptBin` that checks the gateway key file and run directory and then

    exec /nix/store/<hash>-jailed-pi/bin/jailed-pi "$@"

`add-pkg-deps` (`jail-nix/lib/combinators/add-pkg-deps.nix`) renders
`add-path "${lib.getBin pkg}/bin"`, so the caller's packages appear as
`<pkg>/bin` entries in the **inner** launcher's `--setenv PATH …`. A buildEnv is
rendered as the bundle's own `/bin`; its members are NOT flattened. The wrapper
carries none of them.

Two consequences:

1. Any static check of a jail's composition must follow exactly one `exec`
   before grepping — grepping `packages.jail` alone finds nothing.
2. A store *reference* of the wrapper is not a build input of a derivation.
   `builtins.readFile "${jail}/bin/jailed-pi"` returns the text **with the
   wrapper's references in its string context**, so a path extracted from it and
   interpolated into a derivation brings the inner launcher into the sandbox.
   Interpolating a plain path string you computed yourself does not.
