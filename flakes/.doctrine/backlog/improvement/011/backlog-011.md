# IMP-011: Username per host in meta.nix

MULTIHOST follow-up, for the work Mac. `username = "david"` is global; move to `meta.nix` (`username ? "david"`) and key home configs `${username}@<host>`.
