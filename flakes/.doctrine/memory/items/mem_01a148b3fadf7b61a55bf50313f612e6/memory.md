`bwrap --clearenv` clears the environment of the process bwrap execs, not bwrap's own. With `--unshare-pid`, bwrap's monitor is PID 1 inside the jail: same uid and user namespace as the agent, dumpable, no capabilities on either side. Yama `ptrace_scope=1` blocks only attach, not PTRACE_MODE_READ. So `tr '\0' '\n' < /proc/1/environ` inside the jail returns whatever the launching session exported, including `*_API_KEY`.

Verified live on Sleipnir, 2026-10-17 (SL-011 VH-6): jailed eca's own env was clean, and its PID 1 held 7 provider keys.

Fix (b17e348a): build `jail` with `jail-nix.lib.extend { inherit pkgs; bubblewrapPackage = bwrapEmptyEnv; }`, where `bwrapEmptyEnv` is a script named `bwrap` that runs `exec env -i <bubblewrap>/bin/bwrap "$@"`. The clear happens after jail.nix's launcher has expanded `--setenv` values and opened the key file descriptors (21 provider keys, 22 gateway key), which are not close-on-exec, so they survive. bwrap reads only `HOME` from its env, and only without `--chdir`.

Testing: the build sandbox has no user namespaces, so substitute a fake bwrap through `pkgs.extend` that dumps its environ, argv and fds. That runs the real launchers jail.nix generates.

Jails built outside `agents/` get the fix only through jailLib. All of the emacs flake's jails, `jailed-shell` included, build through jailLib and get it (SL-013 research).