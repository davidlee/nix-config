-- nix handles installation; lua loads & configures; lze just manages lazy
-- loading & simplifies some event handler setup / config (e.g. passing keys)
-- mini.deps is for anything we need more recent than nixpkgs

-- make sure lze has loaded mini.deps before we need it; as a nice side affect,
-- we can assume the rest of mini.nvim is available afterwards
require("lze").load({ "mini.nvim", lazy = false, after = function() require("mini.deps") end })

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
