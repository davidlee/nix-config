-- local md = require("mini.deps")
local lz = require("lze")

require("mini.surround").setup({
  mappings = require("config.keymap").mini_surround.mappings,
})

-- editor
lz.load({
  -- yanky
  {
    "yanky.nvim",
    after = function() require("yanky").setup() end,
  },

  -- todo-comments
  {
    "todo-comments.nvim",
    after = function() require("todo-comments").setup({}) end,
  },
})
