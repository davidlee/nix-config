-- vim.pack.add (packfile.lua) handles plugin installation
-- lze handles lazy-loading and configuration
-- nix provides: lze, blink-cmp (binary deps), themes, bootstrapping

require("plugins.lsp")
-- require("plugins.treesitter")
require("plugins.ui")
require("plugins.editor")
require("plugins.movement")
require("plugins.autopairs")
require("plugins.amenities")
require("plugins.format")
require("plugins.file_managers")
require("plugins.completion")
require("plugins.highlight")
require("plugins.lint")
require("plugins.trouble")
require("plugins.modes")
require("plugins.snippets")

-- TODO:
--
-- jghauser/kitty-runner.nvim
-- nvim_highlight_colors
-- persistence-nvim
-- resession-nvim
-- overseer-nvim
-- octo-nvim
-- grug-far-nvim
-- stevearc/stickybuf.nvim
-- https://github.com/wurli/visimatch.nvim
-- https://github.com/nvim-pack/nvim-spectre
