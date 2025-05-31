-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- save a few bytes
local bind = vim.keymap.set

bind("", "<M-PageDown>", "<cmd>bp<cr>")
bind("", "<M-PageUp>", "<cmd>bn<cr>")

bind({ "n", "x" }, "<leader>y", "", { desc = "system clipboard" })

-- system clipboard: copy
bind({ "n", "x" }, "<Leader>yy", '"+y', { desc = "yank to system clipboard" })

-- system clipboard: paste
bind({ "n", "x" }, "<Leader>yp", '"+p', { desc = "paste to system clipboard" })

-- delete char without yank
bind({ "n", "x" }, "X", '"_x', { desc = "delete char without yank" })

-- select all of current buffer
bind("n", "<leader>a", ":keepjumps normal! ggVG<cr>", { desc = "Select entire buffer" })

-- write
bind("n", "<space>!", "<cmd>write<cr>", { desc = "Save" })
