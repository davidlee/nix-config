-- save a few bytes
local bind = vim.keymap.set

-- leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

--
-- global keybinds
--

bind('', '<M-PageUp>',   '<cmd>bp<cr>')
bind('', '<M-PageDown>', '<cmd>bn<cr>')

-- system clipboard: copy
bind({'n', 'x'}, 'gy', '"+y')

-- system clipboard: paste
bind({'n', 'x'}, 'gp', '"+p')

-- x / X delete without yank
bind({'n', 'x'}, 'x', '"_x')
bind({'n', 'x'}, 'X', '"_d')

-- select all of current buffer
bind('n', '<leader>a', ':keepjumps normal! ggVG<cr>')

-- write 
bind('n', '<space>w', '<cmd>write<cr>', {desc = 'Save'})

-- project 
-- > visual file explorer
bind('n', "<leader>pv", vim.cmd.Ex)

