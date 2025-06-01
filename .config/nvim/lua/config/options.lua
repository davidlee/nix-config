-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

local opt = vim.opt

-- respect funky comments in comments at top / end of files
opt.modeline = true

-- Tab set to two spaces
opt.softtabstop = 2

-- Visual aids
opt.hlsearch = true
opt.colorcolumn = "80,120"
opt.listchars = "tab:»·,trail:·,extends:>,precedes:<,nbsp:+"

-- not sure if we want these but they're not in the LazyVim defaults
--

-- Wrapping
--
-- opt.breakindent = true

-- Don't use temp files
--
-- opt.swapfile = false
-- opt.backup = false
opt.smoothscroll = false

-- use edge, build locally
--
-- vim.g.lazyvim_blink_main = true
