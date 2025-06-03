-- amenities
require("lze").load({
  -- which-key
  {
    "which-key.nvim",
    keys = {
      {
        "<leader>?",
        function() require("which-key").show({ global = false }) end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
    after = function() end,
  },

  -- vim-startuptime
  { "vim-startuptime" },

  -- vim-sleuth
  { "vim-sleuth" },

  -- todo-comments
  { "todo-comments.nvim", after = function() require("todo-comments").setup({}) end },
  --[[
vim.keymap.set("n", "]t", function()
  require("todo-comments").jump_next()
end, { desc = "Next todo comment" })

vim.keymap.set("n", "[t", function()
  require("todo-comments").jump_prev()
end, { desc = "Previous todo comment" })
  --]]
})
