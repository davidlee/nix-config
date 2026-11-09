-- Plugin setup. Plugin code: ~/flakes/features/files.nix (nixpkgs)
-- or package.toml (`ya pkg install`).

require("full-border"):setup { set = "rounded" }
require("git"):setup()
require("smart-enter"):setup { open_multi = true }
require("yatline"):setup()
