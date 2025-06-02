-- amenities
require("lze").load({
  {
    "which-key.nvim",
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
    after = function() end,
  },
  { "vim-startuptime" },
  { "vim-sleuth" },
})
