-- set leaders
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("plugins")

require("config.options")
-- TODO ensure these load after lazy plugins
require("config.keymap")

-- put =execute('echo nvim_list_runtime_paths()')
