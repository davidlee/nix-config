-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- save a few bytes
local bind = vim.keymap.set

require("which-key").add({
  -- add headings
  { "<leader>f", group = "File" },
  { "<leader>b", group = "Buffer" },
  { "<leader>s", group = "Snacks picker" },
  { "<leader>g", group = "Git" },
  { "<leader>s", group = "Search" },
  { "<leader>u", group = "Toggles" },
})

-- TODO: export table for snacks.vim to keep stuff all in this file
--
----------------------------------------------------------------------------------------------------
---
-- bind {mode} args:
-- (n)orm (i)ns (x)norm/ins
-- (c)md (v)is (s)elect
-- (o)per (t)erm (l)ang
-- '' :map = nvo
-- ! :map! = ic

--- Normal Mode bindings:
-- X: delete char without yank
bind({ "n", "x" }, "X", '"_x', { desc = "delete char without yank" })

-- Alt-PgUp/Dn: buffer next/prev
bind("", "<A-PageDown>", "<cmd>bp<cr>")
bind("", "<A-PageUp>", "<cmd>bn<cr>")

--- Leader Mode bindings:
-- (y) clipboard
bind({ "n", "x" }, "<leader>y", "", { desc = "Clipboard" })

-- yy: system clipboard: copy
bind({ "n", "x" }, "<leader>yy", '"+y', { desc = "Yank to system clipboard" })

-- yp: system clipboard: paste
bind({ "n", "x" }, "<leader>yp", '"+p', { desc = "Paste to system clipboard" })

-- ya: select entire buffer
bind("n", "<leader>ya", ":keepjumps normal! ggVG<cr>", { desc = "Select entire buffer" })

--- Leader + single char bindings:
-- !: write file
bind("n", "<space>!", "<cmd>write<cr>", { desc = "Save" })

-- file managers
-- f-: (:Triptych)
bind("n", "<leader>f-", "<cmd>Triptych<cr>", { silent = true, desc = "Toggle Triptych" })
-- fo: (:Oil)
bind("n", "<leader>fo", "<cmd>Oil<cr>", { silent = true, desc = "Oil" })
-- fE: (:Ex) Explore with NetRW
bind("n", "<leader>fE", "<cmd>Ex<cr>", { desc = "NetRW (:Ex)" })

--- move lines:
-- normal mode
bind("n", "<A-j>", "<cmd>m .+1<cr>", { desc = "Move line down" })
bind("n", "<A-k>", "<cmd>m .-2<cr>", { desc = "Move line up" })
-- insert mode
bind("i", "<A-j>", "<esc>:m .+1<cr>==gi", { desc = "Move line down" })
bind("i", "<A-k>", "<esc>:m .-2<cr>==gi", { desc = "Move line up" })
-- visual mode
bind("v", "<A-j>", "<cmd>m '>+1<cr>gv=gv", { desc = "Move selected lines down" })
bind("v", "<A-k>", "<cmd>m '<-2<cr>gv=gv", { desc = "Move selected lines up" })
