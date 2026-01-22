-- nix handles installation; lua loads & configures; lze just manages lazy
-- loading & simplifies some event handler setup / config (e.g. passing keys)
-- mini.deps is for anything we need more recent than nixpkgs

-- make sure lze has loaded mini.deps before we need it; as a nice side affect,
-- we can assume the rest of mini.nvim is available afterwards
-- require("lze").load({ "mini.nvim", lazy = false, after = function() require("mini.deps") end })
--

-- Clone 'mini.nvim' manually in a way that it gets managed by 'mini.deps'
local path_package = vim.fn.stdpath("data") .. "/site/"
local mini_path = path_package .. "pack/deps/start/mini.nvim"
if not vim.loop.fs_stat(mini_path) then
  vim.cmd('echo "Installing `mini.nvim`" | redraw')
  local clone_cmd = {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/nvim-mini/mini.nvim",
    mini_path,
  }
  vim.fn.system(clone_cmd)
  vim.cmd("packadd mini.nvim | helptags ALL")
  vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

-- Set up 'mini.deps' (customize to your liking)
require("mini.deps").setup({ path = { package = path_package } })

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
