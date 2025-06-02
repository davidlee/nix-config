-- nix handles installation; lua loads & configures;
-- lze just manages laziness.
--
-- to find nix paths:
-- put =execute('echo nvim_list_runtime_paths()')
require("lze")

-- if we need to manage dependencies we want to keep more current than nixpkgs:
-- require("mini.deps").setup()

require("plugins.mini")
require("plugins.amenities")
require("plugins.editor")
require("plugins.movement")
require("plugins.completion")
require("plugins.format")
require("plugins.ui")
require("plugins.render-markdown")
