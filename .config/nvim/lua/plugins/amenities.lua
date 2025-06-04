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
      {
        "<leader><f1>",
        function() require("which-key").show({ global = true }) end,
        desc = "Global Keymaps (which-key)",
      },
    },
    after = function()
      -- local wk = require("which-key")
      --
      filter = function(mapping)
        -- example to exclude mappings without a description
        -- return mapping.desc and mapping.desc ~= ""
        return true
      end
    end,
  },

  -- vim-startuptime
  { "vim-startuptime" },

  -- vim-sleuth
  { "vim-sleuth" },

  -- todo-comments
  {
    "todo-comments.nvim",
    after = function()
      require("todo-comments").setup({})

      vim.keymap.set("n", "]t", function() require("todo-comments").jump_next() end, { desc = "Next todo comment" })
      vim.keymap.set("n", "[t", function() require("todo-comments").jump_prev() end, { desc = "Previous todo comment" })
    end,
  },
})
