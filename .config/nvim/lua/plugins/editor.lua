-- editor
require("lze").load({
  -- yanky
  {
    "yanky.nvim",
    after = function() require("yanky").setup() end,
  },

  -- mini.surround
  {
    "mini.nvim",
    after = function()
      require("mini.surround").setup({
        mappings = require("config.keymap").mini_surround.mappings,
      })
    end,
  },
})
