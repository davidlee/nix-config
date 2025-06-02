-- just lazy load plugins installed by nix
require("lze")

-- manage dependencies we want to keep more current than nixpkgs
require("mini.deps").setup()

require("plugins.mini")
require("plugins.amenities")
require("plugins.editor")
require("plugins.movement")
require("plugins.completion")
require("plugins.format")
require("plugins.ui")
-- require("plugins.toggleterm")
require("plugins.render-markdown")

-- require('blink.cmp').setup()

-- require('leap')
-- require('fzf-lua').setup()
