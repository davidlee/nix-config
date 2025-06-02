-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- save a few bytes
local bind = vim.keymap.set

-- Normal Mode bindings:
-- X: delete char without yank
bind({ "n", "x" }, "X", '"_x', { desc = "delete char without yank" })

-- Alt-PgUp/Dn: buffer next/prev
bind("", "<M-PageDown>", "<cmd>bp<cr>")
bind("", "<M-PageUp>", "<cmd>bn<cr>")

-- Leader Mode bindings:
-- (y) clipboard
bind({ "n", "x" }, "<leader>y", "", { desc = "system clipboard" })

-- yy: system clipboard: copy
bind({ "n", "x" }, "<Leader>yy", '"+y', { desc = "yank to system clipboard" })

-- yp: system clipboard: paste
bind({ "n", "x" }, "<Leader>yp", '"+p', { desc = "paste to system clipboard" })

-- ya: select entire buffer
bind("n", "<leader>ya", ":keepjumps normal! ggVG<cr>", { desc = "Select entire buffer" })

-- Leader + single char bindings:
-- !: write file
bind("n", "<space>!", "<cmd>write<cr>", { desc = "Save" })
