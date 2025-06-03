require("neo-tree").setup({

  filesystem = {
    hijack_netrw_behavior = "disabled",
  },
  -- keys = {
  --   -- Create a key mapping and lazy-load when it is used
  --   { "<leader>uF", "<CMD>Neotree toggle<CR>", desc = "Toggle NeoTree" },
  -- },
})

-- vim.g.neotree_watching_bufenter = 0
-- vim.g.hijack_netrw_behavior = 0
