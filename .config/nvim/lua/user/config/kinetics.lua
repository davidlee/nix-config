-- kinetics: jump & retrieve 
--
local bind = vim.keymap.set

--
-- FZF
--
bind("n", "<leader>ff", require('fzf-lua').files)
bind("n", "<leader>fb", require('fzf-lua').buffers)
bind("n", "<leader>ft", require('fzf-lua').tabs)
bind("n", "<leader>fo", require('fzf-lua').oldfiles)
bind("n", "<leader>fg", require('fzf-lua').grep)
bind("n", "<leader>fl", require('fzf-lua').git_files)

--
-- Harpoon2
--
local harpoon = require("harpoon")
harpoon:setup()

bind("n", "<leader>ha", function() harpoon:list():add() end)
bind("n", "<leader>hl", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

bind("n", "<leader>h1", function() harpoon:list():select(1) end)
bind("n", "<leader>h2", function() harpoon:list():select(2) end)
bind("n", "<leader>h3", function() harpoon:list():select(3) end)
bind("n", "<leader>h4", function() harpoon:list():select(4) end)

-- Toggle previous & next buffers stored within Harpoon list
bind("n", "<leader>hh", function() harpoon:list():prev() end)
bind("n", "<leader>he", function() harpoon:list():next() end)

--
-- Aerial
--
require("aerial").setup({
  -- optionally use on_attach to set keymaps when aerial has attached to a buffer
  on_attach = function(bufnr)
    -- Jump forwards/backwards with '{' and '}'
    vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
    vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
  end,
})
-- You probably also want to set a keymap to toggle aerial
vim.keymap.set("n", "<leader>e", "<cmd>AerialToggle!<CR>")
--

