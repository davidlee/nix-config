-- set up leader keys first
vim.g.mapleader = " "
vim.g.maplocalleader = ","

require("config.options")
require("config.colorscheme")

require("plugins")

-- TODO ensure these load after lazy plugins
require("config.keymap")
