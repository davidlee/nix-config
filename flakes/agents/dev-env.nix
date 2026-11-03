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
  # The env and its packages for one platform.
  for = pkgs: let
    linux = pkgs.stdenv.isLinux;
  in {
    env =
      env
      // (
        if linux
        then linuxEnv
        else {}
      );
    packages =
      [pkgs.sccache]
      ++ (
        if linux
        then [pkgs.mold]
        else []
      );
  };
}
