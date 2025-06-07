require("lze").load({
  -- folke/trouble
  "trouble.nvim",
  keys = require("config.keymap").trouble.keys,
  after = function()
    require("trouble").setup({
      cmd = "Trouble",
    })
  end,
})
