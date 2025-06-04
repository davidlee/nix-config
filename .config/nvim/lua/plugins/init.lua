-- nix handles installation; lua loads & configures;
-- lze just manages lazy loading & simplifies some event handler setup / config
-- (e.g. passing keys)
require("lze")

-- for managing dependencies unavailable on nixpkgs, or which need to be
-- fresher this looks like it could eventually be The Way, but needs more
-- support from plugin authors.
--
-- Loads without errors, but unused.
-- require("rocks")

require("plugins.ui")
require("plugins.editor")
require("plugins.movement")
require("plugins.autopairs")
require("plugins.amenities")
require("plugins.format")
require("plugins.file_managers")
require("plugins.treesitter")
require("plugins.lsp")
require("plugins.completion")
require("plugins.lint")
require("plugins.trouble")
require("plugins.modes")
require("plugins.snippets")

-- TODO:
--
-- jghauser/kitty-runner.nvim
-- nvim_highlight_colors
-- outline-nvim
-- persistence-nvim
-- resession-nvim
-- overseer-nvim
-- octo-nvim
-- grug-far-nvim
-- smart-splits-nvim
-- stevearc/stickybuf.nvim
