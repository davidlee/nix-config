# agents/dev-env.nix — the env every project gets on this host: host shells
# (the dev.env feature) and every jail, form and consumer shell (dev-envs).
# A variable and the package that makes it work are one fact: whoever applies
# one applies both (RUSTC_WRAPPER without sccache breaks every cargo call).
rec {
  env = {
    CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1";
    RUSTC_WRAPPER = "sccache";
    UV_PYTHON_PREFERENCE = "only-system";
  };
  linuxEnv.CARGO_BUILD_RUSTFLAGS = "-C link-arg=-fuse-ld=mold"; # mold cannot emit Mach-O
  # Host shells only, never a jail; Linux, where jails run (darwin has neither
  # jails nor XDG_RUNTIME_DIR). sccache's server runs the compiler, and its
  # default address, TCP 127.0.0.1:4226, is shared with every networked jail:
  # a jailed cargo would compile, build scripts included, on the host (SL-023
  # PHASE-07 F-1, RSK-001). The host's server listens on a socket under
  # $XDG_RUNTIME_DIR, which the library's jails do not bind; each keeps its own
  # (jailed-agents.nix, envOptions). A jail that sees all of / must set its own:
  # doctrine:scripts/spawn-confined.sh does (RV-047 F-1).
  linuxHostOnlyEnv.SCCACHE_SERVER_UDS = "\${XDG_RUNTIME_DIR}/sccache.sock";
  # The env and its packages for one platform.
  for = pkgs: let
    linux = pkgs.stdenv.isLinux;
    onLinux = attrs:
      if linux
      then attrs
      else {};
  in {
    env = env // onLinux linuxEnv;
    hostOnlyEnv = onLinux linuxHostOnlyEnv;
    packages =
      [pkgs.sccache]
      ++ (
        if linux
        then [pkgs.mold]
        else []
      );
  };
}
