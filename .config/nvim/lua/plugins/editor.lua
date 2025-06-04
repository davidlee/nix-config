-- editor
-- TODO: prolly move to debug.lua
require("plugins.trouble")
require("plugins.autopairs")
require("plugins.lint")

require("lze").load({
  {
    "yanky.nvim",
    after = function() require("yanky").setup() end,
  },

  -- mini.surround
  -- INFO: note the conflict with leap.nvim default bindings
  {
    "mini.nvim",
    after = function()
      require("mini.surround").setup({
        mappings = require("config.keymap").mini_surround.mappings,
      })
    end,
  },
})
