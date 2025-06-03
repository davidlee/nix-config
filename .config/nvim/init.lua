-- set up leader keys first
vim.g.mapleader = " "
vim.g.maplocalleader = ","

require("config.options")
require("config.colorscheme")

require("plugins")

require("config.keymap")
