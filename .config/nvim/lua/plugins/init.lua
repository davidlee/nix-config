-- nix handles installation; lua loads & configures;
-- lze just manages laziness.
--
-- to find nix paths:
-- put =execute('echo nvim_list_runtime_paths()')
require("lze")

-- for managing dependencies unavailable on nixpkgs, or which need to be fresher
--
-- looks like it could be The Way, but needs more support from plugin authors
require("rocks")

require("plugins.mini")
require("plugins.amenities")
require("plugins.editor")
require("plugins.movement")
require("plugins.completion")
require("plugins.format")
require("plugins.ui")

-- require("plugins.render-markdown")
require("plugins.modes")
