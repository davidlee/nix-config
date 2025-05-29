-- save a few bytes
local bind = vim.keymap.set

-- leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

--
-- global keybinds
--


bind('', '<M-PageDown>', '<cmd>bp<cr>')
bind('', '<M-PageUp>',   '<cmd>bn<cr>')

-- system clipboard: copy
bind({'n', 'x'}, 'gy', '"+y', {desc = 'yank to system clipboard'})

-- system clipboard: paste
bind({'n', 'x'}, 'gp', '"+p', { desc = 'paste to system clipboard'})

-- x / X delete without yank
bind({'n', 'x'}, 'x', '"_x', { desc = 'delete char without yank'})
bind({'n', 'x'}, 'X', '"_d', { desc = 'delete line without yank'})

-- select all of current buffer
bind('n', '<leader>a', ':keepjumps normal! ggVG<cr>', {desc = 'Select entire buffer'})

-- write 
bind('n', '<space>w', '<cmd>write<cr>', {desc = 'Save'})

-- project 
-- > visual file explorer
bind('n', "<leader>pv", vim.cmd.Ex, {desc = 'project > visual file explorer'})

