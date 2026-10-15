Turning off `programs.<x>.enable` (even with `mkForce false`) removes only
what that module adds. A package listed elsewhere — a `home.packages` bucket
(`modules/shared/cli/_packages/*.nix` `common`), `environment.systemPackages`,
another module's dependency — stays in the closure and still builds.

Observed (SL-004, ISS-007): `programs.atuin.enable = lib.mkForce false` on
darwin evaluated false, but `shell-ux.nix` still put atuin in the darwin
home, which kept building the uncached atuin.

Verify removal by closure, not by option:

```bash
d=$(nix eval --raw '.#homeConfigurations."david@<host>".activationPackage.drvPath' <overrides>)
nix-store -qR "$d" | grep -i <pkg>     # expect nothing
```

To drop one platform's copy without moving list order (drvs gate), split
the list: `[a b] ++ lib.optional stdenv.hostPlatform.isLinux x ++ [c d]`.
