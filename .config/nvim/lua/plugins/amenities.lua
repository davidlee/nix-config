-- amenities
require("lze").load({
  -- which-key
  {
    "which-key.nvim",
    keys = require("config.keymap").which_key.keys,
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
    after = function() require("todo-comments").setup({}) end,
  },
})
